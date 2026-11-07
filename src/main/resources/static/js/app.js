/* global Chart, bootstrap, lucide */

const state = {
    goods: { page: 1, size: 10, list: [] },
    warning: { page: 1, size: 10, list: [] },
    inbound: { page: 1, size: 10, list: [] },
    outbound: { page: 1, size: 10, list: [] },
    user: { page: 1, size: 10, list: [] },
    log: { page: 1, size: 20, list: [] }
};

let currentUser = null;
let currentGoodsList = [];
let trendChart = null;
let warehouseChart = null;
let warningChart = null;
let categoryChart = null;
let statsChart = null;
let dashboardTrend = [];
let appStarted = false;
let confirmResolver = null;
let toastTimer = null;
let resetUserId = null;
let bindUserId = null;
let sessionLoginAt = null;
let isAdmin = false;
let canOperate = false;

const CHART_COLORS = ['#2563eb', '#f59e0b', '#14b8a6', '#8b5cf6', '#ef4444', '#0ea5e9', '#64748b'];

/* ---------------- 基础工具 ---------------- */

async function api(url, options = {}) {
    const res = await fetch(url, options);
    if (res.status === 401 && !url.includes('/api/auth/')) {
        showLogin('登录已过期，请重新登录');
    }
    if (!res.ok) {
        let message = await res.text();
        try {
            const body = JSON.parse(message);
            if (body && body.message) message = body.message;
        } catch (e) { /* 非 JSON 错误体 */ }
        throw new Error(message || `请求失败（${res.status}）`);
    }
    if (res.status === 204) return null;
    const text = await res.text();
    return text ? JSON.parse(text) : null;
}

const jsonHeaders = { 'Content-Type': 'application/json' };

const escapeHtml = value => String(value ?? '').replace(/[&<>"']/g, ch => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
}[ch]));

const formatTime = value => value ? new Date(value).toLocaleString('zh-CN', { hour12: false }) : '—';

function toast(message) {
    const el = document.getElementById('toast');
    if (!el) return;
    el.textContent = message;
    el.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => el.classList.remove('show'), 2600);
}

function loadingRow(cols) {
    return `<tr><td colspan="${cols}" class="state-cell"><div class="state"><p>加载中…</p></div></td></tr>`;
}

function errorRow(cols, retry) {
    return `<tr><td colspan="${cols}" class="state-cell"><div class="state">
        <p>加载失败，请稍后重试</p>
        <button class="btn btn-secondary btn-sm" type="button" onclick="${retry}()">重新加载</button>
    </div></td></tr>`;
}

function emptyRow(cols, text, actionHtml = '') {
    return `<tr><td colspan="${cols}" class="state-cell"><div class="state">
        <p>${escapeHtml(text)}</p>${actionHtml}
    </div></td></tr>`;
}

function updatePager(key, total) {
    const s = state[key];
    const pages = Math.max(1, Math.ceil(total / s.size));
    if (s.page > pages) s.page = pages;

    const totalEl = document.getElementById(key + 'Total');
    if (totalEl) totalEl.textContent = `共 ${total} 条`;

    const info = document.getElementById(key + 'PageInfo');
    if (info) info.textContent = `${s.page} / ${pages}`;

    const prev = document.getElementById(key + 'Prev');
    const next = document.getElementById(key + 'Next');
    if (prev) prev.disabled = s.page <= 1;
    if (next) next.disabled = s.page >= pages;
}

function pageSlice(key, list) {
    const s = state[key];
    const pages = Math.max(1, Math.ceil(list.length / s.size));
    if (s.page > pages) s.page = pages;
    const start = (s.page - 1) * s.size;
    return list.slice(start, start + s.size);
}

/** 新增成功后回到第一页并清掉搜索词，否则新记录可能被分页/筛选挡住 */
function showListStart(key, searchId) {
    state[key].page = 1;
    const search = document.getElementById(searchId);
    if (search) search.value = '';
}

function segmented(name, value, label, checked) {
    return `<label class="seg"><input type="radio" name="${name}" value="${escapeHtml(value)}" ${checked === value ? 'checked' : ''}><span>${escapeHtml(label)}</span></label>`;
}

/* ---------------- 确认框 ---------------- */

function askConfirm(title, message, confirmText = '彻底删除') {
    return new Promise(resolve => {
        confirmResolver = resolve;
        document.getElementById('confirmTitle').textContent = title;
        document.getElementById('confirmMessage').textContent = message;
        document.getElementById('confirmOk').textContent = confirmText;
        bootstrap.Modal.getOrCreateInstance(document.getElementById('confirmDialog')).show();
    });
}

/* ---------------- 登录 ---------------- */

function showLogin(message) {
    const overlay = document.getElementById('loginOverlay');
    const err = document.getElementById('loginError');
    if (err) err.textContent = message || '';
    if (overlay) overlay.style.display = 'flex';
    document.body.style.overflow = 'hidden';
    document.getElementById('loginPassword')?.focus();
}

function hideLogin() {
    const overlay = document.getElementById('loginOverlay');
    if (overlay) overlay.style.display = 'none';
    document.body.style.overflow = '';
    const err = document.getElementById('loginError');
    if (err) err.textContent = '';
}

async function doLogin() {
    const username = document.getElementById('loginUsername').value.trim();
    const password = document.getElementById('loginPassword').value;
    const err = document.getElementById('loginError');
    if (!username || !password) {
        err.textContent = '请输入用户名和密码';
        return;
    }
    err.textContent = '';
    try {
        currentUser = await api('/api/auth/login', {
            method: 'POST', headers: jsonHeaders,
            body: JSON.stringify({ username, password })
        });
        sessionLoginAt = new Date();
        sessionStorage.setItem('loginAt', sessionLoginAt.toISOString());
        document.getElementById('loginPassword').value = '';
        hideLogin();
        await startApp();
    } catch (e) {
        err.textContent = e.message;
    }
}

async function checkSession() {
    try {
        const res = await fetch('/api/auth/me');
        if (!res.ok) return false;
        currentUser = await res.json();
        if (!sessionLoginAt) {
            sessionLoginAt = new Date();
            sessionStorage.setItem('loginAt', sessionLoginAt.toISOString());
        }
        return true;
    } catch (e) {
        return false;
    }
}

function roleLabel(role) {
    if (!role) return '—';
    if (role === 'ADMIN') return '管理员';
    if (role === 'WAREHOUSE') return '仓库员';
    return '只读';
}

function roleSummary(user) {
    if (!user) return '—';
    if (user.role === 'ADMIN') return '管理员';
    if (user.role === 'WAREHOUSE') {
        return user.warehouse ? `仓库员 · ${user.warehouse}` : '仓库员 · 未绑定仓库';
    }
    return '只读';
}

function applyDashboardLabels() {
    const isWarehouse = currentUser?.role === 'WAREHOUSE';
    const texts = isWarehouse
        ? ['本仓库存', '本仓低库存', '本仓本月入库', '本仓本月出库']
        : ['总库存', '低库存 SKU', '本月入库', '本月出库'];
    document.querySelectorAll('#dashboardView .kpi-label').forEach((el, index) => {
        if (texts[index]) el.textContent = texts[index];
    });

    const dashNav = document.querySelector('[data-view="dashboardView"]');
    if (dashNav) {
        dashNav.dataset.title = isWarehouse ? '工作台' : '库存仪表板';
        const label = dashNav.querySelector('span');
        if (label) label.textContent = isWarehouse ? '工作台' : '仪表板';
        if (document.getElementById('dashboardView')?.classList.contains('active')) {
            setText('pageTitle', isWarehouse ? '工作台' : '库存仪表板');
        }
    }
}

function updateWarehouseKpis() {
    if (currentUser?.role !== 'WAREHOUSE') return;
    const goods = visibleGoods();
    const total = goods.reduce((sum, g) => sum + (g.currentStock || 0), 0);
    const low = goods.filter(g => (g.currentStock ?? 0) < (g.minStock ?? 0)).length;
    setText('totalStock', total);
    setText('lowStockSku', low);

    const now = new Date();
    const monthSum = (list, timeKey) => (list || [])
        .filter(item => {
            const d = new Date(item[timeKey]);
            return !isNaN(d.getTime())
                && d.getFullYear() === now.getFullYear()
                && d.getMonth() === now.getMonth();
        })
        .reduce((sum, item) => sum + (item.quantity || 0), 0);
    setText('kpiInbound', monthSum(state.inbound.list, 'inboundTime'));
    setText('kpiOutbound', monthSum(state.outbound.list, 'outboundTime'));
}

function applyCurrentUser() {
    if (!currentUser) return;
    const name = currentUser.username || '—';
    const initial = name.charAt(0).toUpperCase();
    const summary = roleSummary(currentUser);

    setText('sidebarMeName', name);
    setText('sidebarMeAvatar', initial);
    setText('sidebarMeRole', summary);
    applyDashboardLabels();
}

function openUserInfo() {
    if (!currentUser) return;
    const isAdmin = currentUser.role === 'ADMIN';
    const isWarehouse = currentUser.role === 'WAREHOUSE';
    const warehouse = currentUser.warehouse || '';

    setText('userInfoAvatar', (currentUser.username || 'U').charAt(0).toUpperCase());
    setText('userInfoName', currentUser.username || '—');
    setText('userInfoRole', roleSummary(currentUser));
    setText('userInfoId', currentUser.id ?? '—');
    setText('userInfoRoleText', roleLabel(currentUser.role));
    setText('userInfoWarehouse', isAdmin ? '不限（全部仓库）' : (isWarehouse ? (warehouse || '未绑定') : '—'));
    setText('userInfoScope', isAdmin ? '全部仓库' : (isWarehouse ? (warehouse ? `仅「${warehouse}」` : '未绑定仓库') : '全部仓库（只读）'));
    setText('userInfoLoginTime', sessionLoginAt
        ? sessionLoginAt.toLocaleString('zh-CN', { hour12: false })
        : '当前会话');
    setText('userInfoPermissions', isAdmin
        ? '仪表板、预警、商品、入库、出库、用户管理、库存统计'
        : (isWarehouse
            ? '仪表板、预警、商品、入库、出库、库存统计（仅本仓）'
            : '仪表板、预警、商品、入库、出库、库存统计（只读）'));

    bootstrap.Modal.getOrCreateInstance(document.getElementById('userInfoModal')).show();
}

async function logout() {
    if (!confirm('确定退出登录吗？')) return;
    try { await fetch('/api/auth/logout', { method: 'POST' }); } catch (e) { /* ignore */ }
    sessionStorage.removeItem('loginAt');
    currentUser = null;
    location.reload();
}

function applyPermissions() {
    const role = currentUser?.role || '';
    isAdmin = role === 'ADMIN';
    canOperate = role === 'ADMIN' || role === 'WAREHOUSE';

    document.body.classList.remove('role-admin', 'role-warehouse', 'role-viewer');
    document.body.classList.add(role === 'ADMIN' ? 'role-admin'
        : role === 'WAREHOUSE' ? 'role-warehouse' : 'role-viewer');

    document.querySelectorAll('[data-perm="admin"]').forEach(el => {
        el.style.display = isAdmin ? '' : 'none';
    });
    document.querySelectorAll('[data-perm="operate"]').forEach(el => {
        el.style.display = canOperate ? '' : 'none';
    });

    if (!isAdmin && document.getElementById('userView')?.classList.contains('active')) {
        document.querySelector('[data-view="dashboardView"]')?.click();
    }
}

function requireAdmin() {
    if (!isAdmin) {
        toast('仅管理员可执行该操作');
        return false;
    }
    return true;
}

function requireOperate() {
    if (!canOperate) {
        toast('当前账号为只读角色，无法执行该操作');
        return false;
    }
    return true;
}

async function logout() {
    if (!confirm('确定退出登录吗？')) return;
    try { await fetch('/api/auth/logout', { method: 'POST' }); } catch (e) { /* ignore */ }
    currentUser = null;
    location.reload();
}

/* ---------------- 仪表板 ---------------- */

async function loadDashboard() {
    try {
        const data = await api('/api/statistics/dashboard');
        dashboardTrend = data.trend || [];
        setText('totalStock', data.totalStock ?? 0);
        const lowSku = currentUser?.role === 'WAREHOUSE'
            ? visibleGoods().filter(g => (g.currentStock ?? 0) < (g.minStock ?? 0)).length
            : (data.lowStockSku ?? 0);
        setText('lowStockSku', lowSku);
        setText('kpiInbound', data.monthlyInbound ?? 0);
        setText('kpiOutbound', data.monthlyOutbound ?? 0);
        setText('statsTotalStock', data.totalStock ?? 0);

        const trend = data.trend || [];
        if (trendChart) {
            trendChart.data.labels = trend.map(x => x.label);
            trendChart.data.datasets[0].data = trend.map(x => x.inbound || 0);
            trendChart.data.datasets[1].data = trend.map(x => x.outbound || 0);
            trendChart.update();
        }
        updateDelta('kpiInboundDelta', trend, 'inbound');
        updateDelta('kpiOutboundDelta', trend, 'outbound');
        updateWarehouseKpis();
        refreshDashboardCharts();
    } catch (e) {
        toast(e.message);
    }
}

function updateDelta(id, trend, key) {
    const el = document.getElementById(id);
    if (!el) return;
    if (!trend || trend.length < 2) {
        el.textContent = '较上月 —';
        el.className = 'kpi-delta';
        return;
    }
    const prev = trend[trend.length - 2][key] || 0;
    const current = trend[trend.length - 1][key] || 0;
    if (prev === 0) {
        el.textContent = current > 0 ? '较上月 新增' : '较上月 —';
        el.className = 'kpi-delta';
        return;
    }
    const pct = ((current - prev) / prev) * 100;
    el.textContent = `较上月 ${pct >= 0 ? '+' : ''}${pct.toFixed(1)}%`;
    el.className = 'kpi-delta ' + (pct >= 0 ? 'up' : 'down');
}

function refreshDashboardCharts() {
    updateWarehouseChart();
    updateWarningChart();
    updateCategoryChart();
    renderReplenishment();
}

function groupStock(items, keyFn) {
    const map = new Map();
    items.forEach(item => {
        const key = keyFn(item) || '未分类';
        map.set(key, (map.get(key) || 0) + (item.currentStock || 0));
    });
    return [...map.entries()].map(([label, value]) => ({ label, value }));
}

function updateWarehouseChart() {
    updateDoughnut(warehouseChart, groupStock(visibleGoods(), g => g.warehouse));
}

function updateCategoryChart() {
    updateDoughnut(categoryChart, groupStock(visibleGoods(), g => g.category || '未分类'));
}

function updateWarningChart() {
    const list = state.warning.list || [];
    updateDoughnut(warningChart, [
        { label: '低库存', value: list.filter(w => w.warningType === '低库存预警').length },
        { label: '高库存', value: list.filter(w => w.warningType === '高库存预警').length }
    ]);
}

function updateDoughnut(chart, entries) {
    if (!chart) return;
    const data = (entries || []).filter(x => x.value > 0);
    if (!data.length) {
        chart.data.labels = ['暂无数据'];
        chart.data.datasets[0].data = [1];
        chart.data.datasets[0].backgroundColor = ['#e2e8f0'];
    } else {
        chart.data.labels = data.map(x => x.label);
        chart.data.datasets[0].data = data.map(x => x.value);
        chart.data.datasets[0].backgroundColor = data.map((_, i) => CHART_COLORS[i % CHART_COLORS.length]);
    }
    chart.update();
}

function renderReplenishment() {
    const box = document.getElementById('replenishList');
    const badge = document.getElementById('replenishCount');
    if (!box) return;
    const low = visibleGoods()
        .filter(g => (g.currentStock ?? 0) < (g.minStock ?? 0))
        .sort((a, b) => ((b.minStock - b.currentStock) - (a.minStock - a.currentStock)))
        .slice(0, 6);
    if (badge) badge.textContent = `${low.length} 项`;
    if (!low.length) {
        box.innerHTML = '<div class="replenish-empty">库存健康，暂无补货建议</div>';
        return;
    }
    box.innerHTML = low.map(g => {
        const suggest = Math.max((g.maxStock ?? 0) - (g.currentStock ?? 0), 1);
        const action = canOperate
            ? `<button class="btn btn-primary btn-sm" type="button" onclick="openInboundFor(${g.id})">补货</button>`
            : '';
        return `<div class="replenish-item">
            <div>
                <div class="replenish-name">${escapeHtml(g.name)}</div>
                <div class="replenish-meta">${escapeHtml(g.code)} · ${escapeHtml(g.warehouse)} · 当前 ${g.currentStock ?? 0} / 最低 ${g.minStock ?? 0}</div>
            </div>
            <div class="replenish-action">
                <span class="replenish-suggest">建议 +${suggest}</span>
                ${action}
            </div>
        </div>`;
    }).join('');
}

async function openInboundFor(goodsId) {
    if (!requireOperate()) return;
    await ensureGoodsLoaded();
    const select = document.getElementById('inboundGoodsId');
    const modalEl = document.getElementById('addInboundModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modalEl.addEventListener('shown.bs.modal', () => {
        select.value = String(goodsId);
    }, { once: true });
    modal.show();
    document.getElementById('inboundQty').value = '';
    document.getElementById('inboundError').textContent = '';
}

function resizeDashboardCharts() {
    [trendChart, warehouseChart, warningChart, categoryChart].forEach(chart => {
        if (chart) chart.resize();
    });
}

function setText(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
}

/* ---------------- 预警 ---------------- */

async function loadWarnings() {
    try {
        state.warning.list = await api('/api/warnings');
        const hint = document.getElementById('warningScopeHint');
        const title = document.getElementById('warningCardTitle');
        const dashboardTitle = document.getElementById('dashboardWarningTitle');
        if (dashboardTitle) {
            dashboardTitle.textContent = currentUser?.role === 'WAREHOUSE' ? '本仓预警' : '预警概况';
        }
        if (hint) {
            if (currentUser?.role === 'WAREHOUSE') {
                hint.textContent = currentUser.warehouse
                    ? `当前账号：${currentUser.username} · ${currentUser.warehouse}，只显示本仓预警`
                    : '当前账号尚未绑定仓库，请联系管理员';
            } else {
                hint.textContent = '';
            }
        }
        if (title) {
            title.textContent = currentUser?.role === 'WAREHOUSE' ? '本仓预警' : '全部预警';
        }
        renderWarningSummary();
        renderDashboardWarnings();
        refreshDashboardCharts();
        if (document.getElementById('warningView').classList.contains('active')) {
            renderWarningView();
        }
    } catch (e) {
        const tbody = document.getElementById('warningTableBody');
        if (tbody) tbody.innerHTML = errorRow(8, 'loadWarnings');
    }
}

function renderWarningSummary() {
    const list = state.warning.list;
    const unprocessed = list.filter(w => w.status === '未处理').length;
    // 口径统一：总预警/低库存/高库存统计全部记录，未处理单独一栏，与顶栏铃铛一致
    setText('totalWarningCount', list.length);
    setText('lowWarningCount', list.filter(w => w.warningType === '低库存预警').length);
    setText('highWarningCount', list.filter(w => w.warningType === '高库存预警').length);
    setText('unprocessedCount', unprocessed);
    updateNoticeBanner();
}

/** 顶栏横幅：只放粗略信息（库存总量、待处理预警、低库存 SKU），细节进预警页看 */
function updateNoticeBanner() {
    const banner = document.getElementById('noticeBanner');
    const label = document.getElementById('noticeText');
    if (!banner || !label) return;

    const goods = visibleGoods();
    const totalStock = goods.reduce((sum, g) => sum + (g.currentStock || 0), 0);
    const lowSku = goods.filter(g => (g.currentStock ?? 0) < (g.minStock ?? 0)).length;
    const pending = (state.warning.list || []).filter(w => w.status === '未处理').length;

    const parts = [`库存 ${totalStock}`];
    parts.push(pending > 0 ? `${pending} 条预警待处理` : '暂无待处理预警');
    if (lowSku > 0) parts.push(`${lowSku} 个 SKU 低于最低线`);

    label.textContent = parts.join(' · ');
    const compact = document.getElementById('noticeCompact');
    if (compact) compact.textContent = pending > 0 ? `${pending} 条预警` : '正常';
    const alert = pending > 0 || lowSku > 0;
    banner.classList.toggle('is-alert', alert);
    banner.classList.toggle('is-ok', !alert);
    banner.title = alert ? '点击处理待处理预警' : '库存水位正常，点击查看预警';
}

function pendingWarnings() {
    return (state.warning.list || []).filter(w => w.status === '未处理');
}

async function openNoticeModal() {
    if (!pendingWarnings().length) {
        try { await loadWarnings(); } catch (e) { /* 保持当前数据 */ }
    }
    renderNoticeModal();
    bootstrap.Modal.getOrCreateInstance(document.getElementById('noticeModal')).show();
}

/** 横幅弹窗：只列未处理预警，每条可一键处理 */
function renderNoticeModal() {
    const list = document.getElementById('noticeList');
    const summary = document.getElementById('noticeModalSummary');
    if (!list || !summary) return;

    const pending = pendingWarnings();
    const low = pending.filter(w => w.warningType === '低库存预警').length;
    const stock = visibleGoods().reduce((sum, g) => sum + (g.currentStock || 0), 0);

    summary.textContent = pending.length
        ? `${pending.length} 条待处理（低库存 ${low} / 高库存 ${pending.length - low}）· 库存合计 ${stock}`
        : `暂无待处理预警 · 库存合计 ${stock}`;

    if (!pending.length) {
        list.innerHTML = '<div class="notice-empty">库存水位正常，没有需要处理的预警。</div>';
        return;
    }

    list.innerHTML = pending.map(w => `
        <div class="notice-item">
            <div class="notice-item-main">
                <div class="notice-item-title">
                    ${escapeHtml(w.goodsName)}
                    <span class="notice-item-code">${escapeHtml(w.goodsCode || '')}</span>
                </div>
                <div class="notice-item-meta">
                    ${escapeHtml(w.warehouse || '—')} · 当前 ${w.currentStock ?? 0} / 最低 ${w.minStock ?? 0} · ${escapeHtml((w.warningType || '').replace('预警', ''))}
                </div>
            </div>
            ${canOperate
                ? `<button class="btn btn-sm btn-primary" type="button" onclick="processNoticeWarning(${w.id})">处理</button>`
                : '<span class="notice-item-readonly">只读</span>'}
        </div>`).join('');
}

async function processNoticeWarning(id) {
    if (!requireOperate()) return;
    try {
        await api(`/api/warnings/${id}/process`, { method: 'POST' });
        await loadWarnings();
        renderNoticeModal();
        toast('预警已处理');
    } catch (e) {
        toast(e.message);
    }
}

function goNoticeAll() {
    bootstrap.Modal.getInstance(document.getElementById('noticeModal'))?.hide();
    goWarnings();
}

function goWarnings() {
    document.querySelector('[data-view="warningView"]')?.click();
}

function warningTypeBadge(type) {
    return type === '低库存预警'
        ? '<span class="badge badge-low">低库存预警</span>'
        : '<span class="badge badge-high">高库存预警</span>';
}

function warningStatusBadge(status) {
    return status === '已处理'
        ? '<span class="badge bg-secondary">已处理</span>'
        : '<span class="badge bg-warning">未处理</span>';
}

function renderDashboardWarnings() {
    const tbody = document.getElementById('warningTableBody');
    if (!tbody) return;
    const list = currentUser?.role === 'WAREHOUSE'
        ? state.warning.list.filter(w => w.status === '未处理')
        : state.warning.list;
    if (!list.length) {
        tbody.innerHTML = emptyRow(8, '暂无预警记录',
            canOperate ? '<button class="btn btn-secondary btn-sm" type="button" onclick="manualCheck()">手动检查</button>' : '');
        return;
    }
    tbody.innerHTML = list.map(w => `
        <tr>
            <td>${escapeHtml(w.goodsName)}</td>
            <td>${escapeHtml(w.goodsCode)}</td>
            <td>${escapeHtml(w.warehouse)}</td>
            <td>${w.currentStock ?? 0}</td>
            <td>${w.minStock ?? 0}</td>
            <td>${warningTypeBadge(w.warningType)}</td>
            <td>${warningStatusBadge(w.status)}</td>
            <td>${canOperate && w.status === '未处理'
                ? `<button class="btn btn-sm" type="button" onclick="processWarning(${w.id})">处理</button>`
                : '—'}</td>
        </tr>`).join('');
}

function filteredWarnings() {
    const type = document.querySelector('input[name="warningType"]:checked')?.value || '';
    const status = document.querySelector('input[name="warningStatus"]:checked')?.value || '';
    return state.warning.list.filter(w => {
        if (type === 'low' && w.warningType !== '低库存预警') return false;
        if (type === 'high' && w.warningType !== '高库存预警') return false;
        if (status === 'unprocessed' && w.status !== '未处理') return false;
        if (status === 'processed' && w.status !== '已处理') return false;
        return true;
    });
}

function renderWarningView() {
    const tbody = document.getElementById('warningViewTableBody');
    if (!tbody) return;
    const list = filteredWarnings();
    const rows = pageSlice('warning', list);

    if (!rows.length) {
        const action = state.warning.list.length
            ? '<button class="btn btn-secondary btn-sm" type="button" onclick="clearWarningFilters()">清除筛选</button>'
            : (canOperate ? '<button class="btn btn-secondary btn-sm" type="button" onclick="manualCheck()">手动检查</button>' : '');
        tbody.innerHTML = emptyRow(9, state.warning.list.length ? '没有匹配的预警' : '暂无预警记录', action);
    } else {
        tbody.innerHTML = rows.map(w => `
            <tr>
                <td>${escapeHtml(w.goodsName)}</td>
                <td>${escapeHtml(w.goodsCode)}</td>
                <td>${escapeHtml(w.warehouse)}</td>
                <td>${w.currentStock ?? 0}</td>
                <td>${w.minStock ?? 0}</td>
                <td>${warningTypeBadge(w.warningType)}</td>
                <td>${warningStatusBadge(w.status)}</td>
                <td>${formatTime(w.createTime)}</td>
                <td>${canOperate && w.status === '未处理'
                    ? `<button class="btn btn-sm" type="button" onclick="processWarning(${w.id})">处理</button>`
                    : '—'}</td>
            </tr>`).join('');
    }
    updatePager('warning', list.length);
}

function clearWarningFilters() {
    document.querySelectorAll('input[name="warningType"]')[0].checked = true;
    document.querySelectorAll('input[name="warningStatus"]')[0].checked = true;
    state.warning.page = 1;
    renderWarningView();
}

async function manualCheck() {
    if (!requireOperate()) return;
    try {
        await api('/api/warnings/check', { method: 'POST' });
        await loadWarnings();
        toast('预警检查完成');
    } catch (e) {
        toast(e.message);
    }
}

async function processWarning(id) {
    if (!requireOperate()) return;
    try {
        await api(`/api/warnings/${id}/process`, { method: 'POST' });
        await loadWarnings();
        toast('预警已处理');
    } catch (e) {
        toast(e.message);
    }
}

/* ---------------- 商品 ---------------- */

async function loadGoods() {
    const tbody = document.getElementById('goodsTableBody');
    if (tbody) tbody.innerHTML = loadingRow(9);
    try {
        state.goods.list = await api('/api/goods');
        currentGoodsList = state.goods.list;
        populateWarehouseFilter();
        populateCategoryFilter();
        renderGoods();
        setText('statsTotalGoods', visibleGoods().length);
        if (currentUser?.role === 'WAREHOUSE') {
            setText('lowStockSku', visibleGoods().filter(g => (g.currentStock ?? 0) < (g.minStock ?? 0)).length);
        }
        updateWarehouseKpis();
        refreshDashboardCharts();
    } catch (e) {
        if (tbody) tbody.innerHTML = errorRow(9, 'loadGoods');
    }
}

function populateCategoryFilter() {
    const select = document.getElementById('goodsCategoryFilter');
    if (!select) return;
    const current = select.value;
    const categories = [...new Set(visibleGoods().map(g => g.category || '未分类'))].sort();
    select.innerHTML = '<option value="">全部分类</option>'
        + categories.map(c => `<option value="${escapeHtml(c)}">${escapeHtml(c)}</option>`).join('');
    if (current && categories.includes(current)) select.value = current;
}

function populateWarehouseFilter() {
    const box = document.getElementById('goodsWarehouseFilter');
    if (!box) return;
    const checked = box.querySelector('input:checked')?.value || '';
    const warehouses = [...new Set(visibleGoods().map(g => g.warehouse).filter(Boolean))];
    box.innerHTML = segmented('goodsWarehouse', '', '全部', checked)
        + warehouses.map(w => segmented('goodsWarehouse', w, w, checked)).join('');
}

/** 仓库员只看到绑定仓库的商品；管理员/只读看到全部 */
function visibleGoods() {
    if (currentUser?.role === 'WAREHOUSE') {
        if (!currentUser.warehouse) return [];
        return state.goods.list.filter(g => g.warehouse === currentUser.warehouse);
    }
    return state.goods.list;
}

function filteredGoods() {
    const q = (document.getElementById('goodsSearch')?.value || '').trim().toLowerCase();
    const warehouse = document.querySelector('input[name="goodsWarehouse"]:checked')?.value || '';
    const category = document.getElementById('goodsCategoryFilter')?.value || '';
    return visibleGoods().filter(g => {
        const matchText = !q
            || (g.code || '').toLowerCase().includes(q)
            || (g.name || '').toLowerCase().includes(q);
        const matchWarehouse = !warehouse || g.warehouse === warehouse;
        const matchCategory = !category || (g.category || '未分类') === category;
        return matchText && matchWarehouse && matchCategory;
    });
}

function renderGoods() {
    const tbody = document.getElementById('goodsTableBody');
    if (!tbody) return;
    const list = filteredGoods();
    const rows = pageSlice('goods', list);

    const unboundWarehouse = currentUser?.role === 'WAREHOUSE' && !currentUser.warehouse;
    if (unboundWarehouse) {
        tbody.innerHTML = emptyRow(9, '当前账号尚未绑定仓库，请联系管理员', '');
    } else if (!rows.length) {
        let action = '';
        if (state.goods.list.length) {
            action = '<button class="btn btn-secondary btn-sm" type="button" onclick="clearGoodsFilters()">清除筛选</button>';
        } else if (isAdmin) {
            action = '<button class="btn btn-primary btn-sm" type="button" onclick="openAddGoods()">新增商品</button>';
        }
        tbody.innerHTML = emptyRow(9,
            state.goods.list.length ? '没有匹配的商品' : (isAdmin ? '暂无商品数据' : '暂无商品数据，请联系管理员'),
            action);
    } else {
        tbody.innerHTML = rows.map(g => {
            const stockCell = canOperate
                ? `<div class="stock-control">
                        <button type="button" onclick="adjustStock(${g.id}, -1)">−</button>
                        <input value="${g.currentStock ?? 0}" readonly>
                        <button type="button" onclick="adjustStock(${g.id}, 1)">+</button>
                   </div>`
                : `${g.currentStock ?? 0}`;
            const minCell = isAdmin
                ? `<input class="mini-input min-stock-input" type="number" value="${g.minStock ?? 0}" data-id="${g.id}">`
                : `${g.minStock ?? 0}`;
            const maxCell = isAdmin
                ? `<input class="mini-input max-stock-input" type="number" value="${g.maxStock ?? 0}" data-id="${g.id}">`
                : `${g.maxStock ?? 0}`;
            const updateCell = isAdmin
                ? `<button class="btn btn-sm btn-info" type="button" onclick="updateWarningLine(${g.id})">更新</button>`
                : '—';
            const deleteCell = isAdmin
                ? `<button class="btn btn-sm btn-danger" type="button" onclick="deleteGoods(${g.id})">删除</button>`
                : '—';
            return `<tr>
                <td>${escapeHtml(g.code)}</td>
                <td>${escapeHtml(g.name)}</td>
                <td>${escapeHtml(g.category || '未分类')}</td>
                <td>${escapeHtml(g.warehouse)}</td>
                <td>${stockCell}</td>
                <td>${minCell}</td>
                <td>${maxCell}</td>
                <td>${updateCell}</td>
                <td>${deleteCell}</td>
            </tr>`;
        }).join('');
    }
    updatePager('goods', list.length);
    updateNoticeBanner();
}

function clearGoodsFilters() {
    const search = document.getElementById('goodsSearch');
    if (search) search.value = '';
    const all = document.querySelector('input[name="goodsWarehouse"][value=""]');
    if (all) all.checked = true;
    const category = document.getElementById('goodsCategoryFilter');
    if (category) category.value = '';
    state.goods.page = 1;
    renderGoods();
}

function csvCell(value) {
    const text = String(value ?? '');
    return '"' + text.replace(/"/g, '""') + '"';
}

function downloadCsv(filename, headers, rows) {
    const content = [headers, ...rows]
        .map(row => row.map(csvCell).join(','))
        .join('\r\n');
    const blob = new Blob(['\uFEFF' + content], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
}

function dateStamp() {
    const d = new Date();
    return `${d.getFullYear()}${String(d.getMonth() + 1).padStart(2, '0')}${String(d.getDate()).padStart(2, '0')}`;
}

function exportGoods() {
    const list = filteredGoods();
    downloadCsv(`商品库存-${dateStamp()}.csv`,
        ['编码', '名称', '分类', '仓库', '当前库存', '最低预警线', '最高预警线'],
        list.map(g => [g.code, g.name, g.category || '未分类', g.warehouse, g.currentStock, g.minStock, g.maxStock]));
    toast(`已导出 ${list.length} 条商品`);
}

function exportInbounds() {
    const list = filteredInbounds();
    downloadCsv(`入库记录-${dateStamp()}.csv`,
        ['订单号', '商品', '仓库', '数量', '入库时间', '操作人'],
        list.map(x => [x.orderNo, x.goodsName, x.warehouse, x.quantity, formatTime(x.inboundTime), x.operator]));
    toast(`已导出 ${list.length} 条入库记录`);
}

function exportOutbounds() {
    const list = filteredOutbounds();
    downloadCsv(`出库记录-${dateStamp()}.csv`,
        ['订单号', '商品', '仓库', '数量', '出库时间', '操作人'],
        list.map(x => [x.orderNo, x.goodsName, x.warehouse, x.quantity, formatTime(x.outboundTime), x.operator]));
    toast(`已导出 ${list.length} 条出库记录`);
}

async function adjustStock(id, delta) {
    if (!requireOperate()) return;
    try {
        await api(`/api/goods/${id}/stock`, {
            method: 'POST', headers: jsonHeaders, body: JSON.stringify({ delta })
        });
        await Promise.all([loadGoods(), loadDashboard(), loadWarnings()]);
    } catch (e) {
        toast(e.message);
    }
}

async function updateWarningLine(id) {
    if (!requireAdmin()) return;
    const goods = state.goods.list.find(g => g.id === id);
    if (!goods) return;
    const min = document.querySelector(`.min-stock-input[data-id="${id}"]`);
    const max = document.querySelector(`.max-stock-input[data-id="${id}"]`);
    try {
        await api('/api/goods', {
            method: 'POST', headers: jsonHeaders,
            body: JSON.stringify({ ...goods, minStock: Number(min.value), maxStock: Number(max.value) })
        });
        toast('预警线已更新');
        await Promise.all([loadGoods(), loadWarnings()]);
    } catch (e) {
        toast(e.message);
    }
}

async function deleteGoods(id) {
    if (!requireAdmin()) return;
    const goods = state.goods.list.find(g => g.id === id);
    const ok = await askConfirm(
        '删除商品',
        `确定删除「${goods ? goods.name : '该商品'}」？删除后不可恢复，历史出入库流水会保留。`,
        '彻底删除'
    );
    if (!ok) return;
    try {
        await api(`/api/goods/${id}`, { method: 'DELETE' });
        toast('商品已删除');
        await Promise.all([loadGoods(), loadDashboard(), loadWarnings()]);
    } catch (e) {
        toast(e.message);
    }
}

/* ---------------- 入库 / 出库 ---------------- */

async function loadInbounds() {
    const tbody = document.getElementById('inboundTableBody');
    if (tbody) tbody.innerHTML = loadingRow(5);
    try {
        state.inbound.list = await api('/api/inbound');
        renderInbounds();
        updateWarehouseKpis();
    } catch (e) {
        if (tbody) tbody.innerHTML = errorRow(5, 'loadInbounds');
    }
}

function filteredInbounds() {
    const q = (document.getElementById('inboundSearch')?.value || '').trim().toLowerCase();
    return state.inbound.list.filter(item =>
        !q || (item.orderNo || '').toLowerCase().includes(q) || (item.goodsName || '').toLowerCase().includes(q));
}

function renderInbounds() {
    const tbody = document.getElementById('inboundTableBody');
    if (!tbody) return;
    const list = filteredInbounds();
    const rows = pageSlice('inbound', list);

    if (!rows.length) {
        tbody.innerHTML = emptyRow(5, state.inbound.list.length ? '没有匹配的入库单' : '暂无入库记录',
            canOperate ? '<button class="btn btn-primary btn-sm" type="button" onclick="openInbound()">新增入库</button>' : '');
    } else {
        tbody.innerHTML = rows.map(item => `
            <tr>
                <td>${escapeHtml(item.orderNo)}</td>
                <td>${escapeHtml(item.goodsName)}</td>
                <td>${item.quantity ?? 0}</td>
                <td>${formatTime(item.inboundTime)}</td>
                <td>${escapeHtml(item.operator)}</td>
            </tr>`).join('');
    }
    updatePager('inbound', list.length);
}

async function openInbound() {
    if (!requireOperate()) return;
    await ensureGoodsLoaded();
    fillGoodsSelect('inboundGoodsId');
    document.getElementById('inboundQty').value = '';
    document.getElementById('inboundError').textContent = '';
    bootstrap.Modal.getOrCreateInstance(document.getElementById('addInboundModal')).show();
}

async function submitInbound() {
    if (!requireOperate()) return;
    const goodsId = Number(document.getElementById('inboundGoodsId').value);
    const quantity = Number(document.getElementById('inboundQty').value);
    const err = document.getElementById('inboundError');
    if (!goodsId || !quantity || quantity <= 0) {
        err.textContent = '请选择商品并填写正确的数量';
        return;
    }
    err.textContent = '';
    const goods = currentGoodsList.find(g => g.id === goodsId);
    try {
        await api('/api/inbound', {
            method: 'POST', headers: jsonHeaders,
            body: JSON.stringify({ goodsId, goodsName: goods?.name, quantity, orderNo: 'IN-' + Date.now() })
        });
        bootstrap.Modal.getInstance(document.getElementById('addInboundModal')).hide();
        toast('入库成功');
        showListStart('inbound', 'inboundSearch');
        await Promise.all([loadInbounds(), loadGoods(), loadDashboard(), loadWarnings()]);
    } catch (e) {
        err.textContent = e.message;
    }
}

async function loadOutbounds() {
    const tbody = document.getElementById('outboundTableBody');
    if (tbody) tbody.innerHTML = loadingRow(5);
    try {
        state.outbound.list = await api('/api/outbound');
        renderOutbounds();
        updateWarehouseKpis();
    } catch (e) {
        if (tbody) tbody.innerHTML = errorRow(5, 'loadOutbounds');
    }
}

function filteredOutbounds() {
    const q = (document.getElementById('outboundSearch')?.value || '').trim().toLowerCase();
    return state.outbound.list.filter(item =>
        !q || (item.orderNo || '').toLowerCase().includes(q) || (item.goodsName || '').toLowerCase().includes(q));
}

function renderOutbounds() {
    const tbody = document.getElementById('outboundTableBody');
    if (!tbody) return;
    const list = filteredOutbounds();
    const rows = pageSlice('outbound', list);

    if (!rows.length) {
        tbody.innerHTML = emptyRow(5, state.outbound.list.length ? '没有匹配的出库单' : '暂无出库记录',
            canOperate ? '<button class="btn btn-primary btn-sm" type="button" onclick="openOutbound()">新增出库</button>' : '');
    } else {
        tbody.innerHTML = rows.map(item => `
            <tr>
                <td>${escapeHtml(item.orderNo)}</td>
                <td>${escapeHtml(item.goodsName)}</td>
                <td>${item.quantity ?? 0}</td>
                <td>${formatTime(item.outboundTime)}</td>
                <td>${escapeHtml(item.operator)}</td>
            </tr>`).join('');
    }
    updatePager('outbound', list.length);
}

async function openOutbound() {
    if (!requireOperate()) return;
    await ensureGoodsLoaded();
    fillGoodsSelect('outboundGoodsId');
    document.getElementById('outboundQty').value = '';
    document.getElementById('outboundError').textContent = '';
    bootstrap.Modal.getOrCreateInstance(document.getElementById('addOutboundModal')).show();
}

async function submitOutbound() {
    if (!requireOperate()) return;
    const goodsId = Number(document.getElementById('outboundGoodsId').value);
    const quantity = Number(document.getElementById('outboundQty').value);
    const err = document.getElementById('outboundError');
    if (!goodsId || !quantity || quantity <= 0) {
        err.textContent = '请选择商品并填写正确的数量';
        return;
    }
    const goods = currentGoodsList.find(g => g.id === goodsId);
    if (goods && (goods.currentStock ?? 0) < quantity) {
        err.textContent = `库存不足，当前库存 ${goods.currentStock ?? 0}`;
        return;
    }
    err.textContent = '';
    try {
        await api('/api/outbound', {
            method: 'POST', headers: jsonHeaders,
            body: JSON.stringify({ goodsId, goodsName: goods?.name, quantity, orderNo: 'OUT-' + Date.now() })
        });
        bootstrap.Modal.getInstance(document.getElementById('addOutboundModal')).hide();
        toast('出库成功');
        showListStart('outbound', 'outboundSearch');
        await Promise.all([loadOutbounds(), loadGoods(), loadDashboard(), loadWarnings()]);
    } catch (e) {
        err.textContent = e.message;
    }
}

async function ensureGoodsLoaded() {
    if (!currentGoodsList.length) {
        currentGoodsList = await api('/api/goods');
        state.goods.list = currentGoodsList;
    }
}

function fillGoodsSelect(selectId) {
    const select = document.getElementById(selectId);
    if (!select) return;
    const goods = visibleGoods();
    const hintId = selectId === 'inboundGoodsId' ? 'inboundWarehouseHint' : 'outboundWarehouseHint';
    const hint = document.getElementById(hintId);
    if (hint) {
        if (currentUser?.role === 'WAREHOUSE') {
            hint.textContent = currentUser.warehouse
                ? `当前账号：${currentUser.username} · ${currentUser.warehouse}，只显示本仓商品`
                : '当前账号尚未绑定仓库，请联系管理员';
        } else {
            hint.textContent = '管理员可选择全部仓库的商品';
        }
    }
    select.innerHTML = `<option value="">${goods.length ? '请选择商品' : '暂无可选商品'}</option>`
        + goods.map(g => `<option value="${g.id}">${escapeHtml(g.name)}（${escapeHtml(g.code)}）· ${escapeHtml(g.warehouse)}</option>`).join('');
}

/* ---------------- 用户 ---------------- */

async function loadUsers() {
    if (!isAdmin) return;
    const tbody = document.getElementById('userTableBody');
    if (tbody) tbody.innerHTML = loadingRow(6);
    try {
        state.user.list = await api('/api/users');
        renderUsers();
    } catch (e) {
        if (tbody) tbody.innerHTML = errorRow(6, 'loadUsers');
    }
}

function renderUsers() {
    const tbody = document.getElementById('userTableBody');
    if (!tbody) return;
    const q = (document.getElementById('userSearch')?.value || '').trim().toLowerCase();
    const list = state.user.list.filter(u => !q || (u.username || '').toLowerCase().includes(q));
    const rows = pageSlice('user', list);

    if (!rows.length) {
        tbody.innerHTML = emptyRow(6, state.user.list.length ? '没有匹配的用户' : '暂无用户数据',
            '<button class="btn btn-primary btn-sm" type="button" onclick="openAddUser()">新增用户</button>');
    } else {
        tbody.innerHTML = rows.map(u => {
            const roleText = u.role === 'ADMIN' ? '管理员' : u.role === 'WAREHOUSE' ? '仓库员' : '只读';
            const warehouseText = u.role === 'ADMIN' ? '不限' : (u.warehouse || '未绑定');
            const bindBtn = u.role === 'WAREHOUSE'
                ? `<button class="btn btn-sm btn-info btn-bind" type="button" onclick="openBindWarehouse(${u.id}, '${escapeHtml(u.username)}', '${escapeHtml(u.warehouse || '')}')">绑定仓库</button>`
                : '';
            return `<tr>
                <td>${u.id}</td>
                <td>${escapeHtml(u.username)}</td>
                <td>${roleText}</td>
                <td>${escapeHtml(warehouseText)}</td>
                <td>${formatTime(u.createTime)}</td>
                <td>
                    ${bindBtn}
                    <button class="btn btn-sm btn-info" type="button" onclick="openResetPassword(${u.id}, '${escapeHtml(u.username)}')">重置密码</button>
                    <button class="btn btn-sm btn-danger" type="button" onclick="deleteUser(${u.id})">删除</button>
                </td>
            </tr>`;
        }).join('');
    }
    updatePager('user', list.length);
}

function warehouseOptions() {
    return [...new Set([
        ...state.goods.list.map(g => g.warehouse),
        '中心仓库', '二号仓', '冷链仓', '退货仓'
    ].filter(Boolean))];
}

function fillWarehouseOptions(selectId, selected) {
    const select = document.getElementById(selectId);
    if (!select) return;
    select.innerHTML = '<option value="">请选择仓库</option>'
        + warehouseOptions().map(w => `<option value="${escapeHtml(w)}">${escapeHtml(w)}</option>`).join('');
    if (selected) select.value = selected;
}

function syncUserWarehouseField() {
    const role = document.querySelector('input[name="userRole"]:checked')?.value || 'WAREHOUSE';
    const select = document.getElementById('userWarehouse');
    const hint = document.getElementById('userWarehouseHint');
    const needsWarehouse = role === 'WAREHOUSE';
    if (select) {
        select.disabled = !needsWarehouse;
        if (!needsWarehouse) select.value = '';
    }
    if (hint) {
        hint.textContent = needsWarehouse
            ? '仓库员必须绑定一个仓库。'
            : '管理员和只读不需要绑定仓库。';
    }
}

function openResetPassword(id, username) {
    if (!requireAdmin()) return;
    resetUserId = id;
    document.getElementById('resetUsername').textContent = username;
    document.getElementById('resetNewPassword').value = '';
    document.getElementById('resetPasswordError').textContent = '';
    bootstrap.Modal.getOrCreateInstance(document.getElementById('resetPasswordModal')).show();
}

async function submitResetPassword() {
    if (!requireAdmin()) return;
    const password = document.getElementById('resetNewPassword').value;
    const err = document.getElementById('resetPasswordError');
    if (password.length < 6) {
        err.textContent = '新密码至少 6 位';
        return;
    }
    err.textContent = '';
    try {
        await api(`/api/users/${resetUserId}/password`, {
            method: 'POST', headers: jsonHeaders, body: JSON.stringify({ newPassword: password })
        });
        bootstrap.Modal.getInstance(document.getElementById('resetPasswordModal')).hide();
        toast('密码已重置');
    } catch (e) {
        err.textContent = e.message;
    }
}

async function deleteUser(id) {
    if (!requireAdmin()) return;
    const user = state.user.list.find(u => u.id === id);
    const ok = await askConfirm(
        '删除用户',
        `确定删除「${user ? user.username : '该用户'}」？删除后该账号将无法登录，操作不可撤销。`,
        '彻底删除'
    );
    if (!ok) return;
    try {
        await api(`/api/users/${id}`, { method: 'DELETE' });
        toast('用户已删除');
        await loadUsers();
    } catch (e) {
        toast(e.message);
    }
}

/* ---------------- 新增商品 / 用户 / 改密 ---------------- */

function openAddGoods() {
    if (!requireAdmin()) return;
    ['goodsCode', 'goodsName', 'goodsWarehouse'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('goodsCategory').value = '数码配件';
    document.getElementById('goodsStock').value = '0';
    document.getElementById('goodsMinStock').value = '50';
    document.getElementById('goodsMaxStock').value = '200';
    document.getElementById('goodsError').textContent = '';
    bootstrap.Modal.getOrCreateInstance(document.getElementById('addGoodsModal')).show();
}

async function saveGoods() {
    if (!requireAdmin()) return;
    const payload = {
        code: document.getElementById('goodsCode').value.trim(),
        name: document.getElementById('goodsName').value.trim(),
        category: document.getElementById('goodsCategory').value,
        warehouse: document.getElementById('goodsWarehouse').value.trim(),
        currentStock: Number(document.getElementById('goodsStock').value) || 0,
        minStock: Number(document.getElementById('goodsMinStock').value) || 0,
        maxStock: Number(document.getElementById('goodsMaxStock').value) || 0
    };
    const err = document.getElementById('goodsError');
    if (!payload.code || !payload.name || !payload.warehouse) {
        err.textContent = '编码、名称、仓库均不能为空';
        return;
    }
    err.textContent = '';
    try {
        await api('/api/goods', { method: 'POST', headers: jsonHeaders, body: JSON.stringify(payload) });
        bootstrap.Modal.getInstance(document.getElementById('addGoodsModal')).hide();
        toast('商品已创建');
        showListStart('goods', 'goodsSearch');
        const allWarehouses = document.querySelector('input[name="goodsWarehouse"][value=""]');
        if (allWarehouses) allWarehouses.checked = true;
        const categoryFilter = document.getElementById('goodsCategoryFilter');
        if (categoryFilter) categoryFilter.value = '';
        await Promise.all([loadGoods(), loadDashboard(), loadWarnings()]);
    } catch (e) {
        err.textContent = e.message;
    }
}

function openAddUser() {
    if (!requireAdmin()) return;
    document.getElementById('userName').value = '';
    document.querySelector('input[name="userRole"][value="WAREHOUSE"]').checked = true;
    fillWarehouseOptions('userWarehouse', '');
    syncUserWarehouseField();
    document.getElementById('userError').textContent = '';
    bootstrap.Modal.getOrCreateInstance(document.getElementById('addUserModal')).show();
}

async function submitUser() {
    if (!requireAdmin()) return;
    const username = document.getElementById('userName').value.trim();
    const role = document.querySelector('input[name="userRole"]:checked')?.value || 'WAREHOUSE';
    const warehouse = document.getElementById('userWarehouse').value;
    const err = document.getElementById('userError');
    if (!username) {
        err.textContent = '请输入用户名';
        return;
    }
    if (role === 'WAREHOUSE' && !warehouse) {
        err.textContent = '仓库员必须绑定仓库';
        return;
    }
    err.textContent = '';
    try {
        await api('/api/users', {
            method: 'POST', headers: jsonHeaders,
            body: JSON.stringify({ username, role, warehouse: role === 'WAREHOUSE' ? warehouse : null })
        });
        bootstrap.Modal.getInstance(document.getElementById('addUserModal')).hide();
        toast('用户已创建，初始密码 123456');
        showListStart('user', 'userSearch');
        await loadUsers();
    } catch (e) {
        err.textContent = e.message;
    }
}

function openBindWarehouse(id, username, warehouse) {
    if (!requireAdmin()) return;
    bindUserId = id;
    document.getElementById('bindUsername').textContent = username;
    fillWarehouseOptions('bindWarehouse', warehouse || '');
    document.getElementById('bindWarehouseError').textContent = '';
    bootstrap.Modal.getOrCreateInstance(document.getElementById('bindWarehouseModal')).show();
}

async function submitBindWarehouse() {
    if (!requireAdmin()) return;
    const warehouse = document.getElementById('bindWarehouse').value;
    const err = document.getElementById('bindWarehouseError');
    if (!warehouse) {
        err.textContent = '请选择仓库';
        return;
    }
    err.textContent = '';
    try {
        await api(`/api/users/${bindUserId}/warehouse`, {
            method: 'PUT', headers: jsonHeaders,
            body: JSON.stringify({ warehouse })
        });
        bootstrap.Modal.getInstance(document.getElementById('bindWarehouseModal')).hide();
        toast('仓库绑定已更新');
        await loadUsers();
    } catch (e) {
        err.textContent = e.message;
    }
}

function openChangePassword() {
    ['oldPassword', 'newPassword', 'confirmPassword'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('passwordError').textContent = '';
    bootstrap.Modal.getOrCreateInstance(document.getElementById('changePasswordModal')).show();
}

async function submitChangePassword() {
    const oldPassword = document.getElementById('oldPassword').value;
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    const err = document.getElementById('passwordError');
    if (!oldPassword) { err.textContent = '请输入当前密码'; return; }
    if (newPassword.length < 6) { err.textContent = '新密码至少 6 位'; return; }
    if (newPassword !== confirmPassword) { err.textContent = '两次输入的新密码不一致'; return; }
    err.textContent = '';
    try {
        await api('/api/auth/password', {
            method: 'POST', headers: jsonHeaders,
            body: JSON.stringify({ oldPassword, newPassword })
        });
        bootstrap.Modal.getInstance(document.getElementById('changePasswordModal')).hide();
        toast('密码修改成功，下次登录请使用新密码');
    } catch (e) {
        err.textContent = e.message;
    }
}

/* ---------------- 图表 ---------------- */

function initCharts() {
    Chart.defaults.font.family = getComputedStyle(document.body).fontFamily;
    Chart.defaults.color = '#475569';

    const trendCtx = document.getElementById('trendChart');
    if (trendCtx) {
        trendChart = new Chart(trendCtx.getContext('2d'), {
            type: 'line',
            data: {
                labels: [],
                datasets: [
                    {
                        label: '入库',
                        data: [],
                        borderColor: '#2563eb',
                        backgroundColor: 'rgba(37, 99, 235, .08)',
                        fill: true,
                        tension: .35,
                        borderWidth: 2,
                        pointRadius: 3,
                        pointBackgroundColor: '#2563eb'
                    },
                    {
                        label: '出库',
                        data: [],
                        borderColor: '#f59e0b',
                        backgroundColor: 'rgba(245, 158, 11, .08)',
                        fill: true,
                        tension: .35,
                        borderWidth: 2,
                        pointRadius: 3,
                        pointBackgroundColor: '#f59e0b'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: {
                        position: 'top',
                        align: 'end',
                        labels: { boxWidth: 8, usePointStyle: true, padding: 16, font: { size: 12 } }
                    },
                    tooltip: {
                        callbacks: { label: ctx => `${ctx.dataset.label}：${ctx.parsed.y}` }
                    }
                },
                scales: {
                    x: { grid: { display: false }, border: { display: false }, ticks: { font: { size: 11 } } },
                    y: { beginAtZero: true, grid: { color: '#e2e8f0' }, border: { display: false }, ticks: { precision: 0, font: { size: 11 } } }
                }
            }
        });
    }

    warehouseChart = createDoughnut('warehouseChart');
    warningChart = createDoughnut('warningChart');
    categoryChart = createDoughnut('categoryChart');

    const statsCtx = document.getElementById('statsChart');
    if (statsCtx) {
        statsChart = new Chart(statsCtx.getContext('2d'), {
            type: 'bar',
            data: {
                labels: ['总库存', '本月入库', '本月出库'],
                datasets: [{ data: [0, 0, 0], backgroundColor: '#2563eb', borderRadius: 4, maxBarThickness: 72 }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: { grid: { display: false }, border: { display: false } },
                    y: { beginAtZero: true, grid: { color: '#e2e8f0' }, border: { display: false }, ticks: { precision: 0 } }
                }
            }
        });
    }
}

function createDoughnut(id) {
    const el = document.getElementById(id);
    if (!el) return null;
    return new Chart(el.getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: ['暂无数据'],
            datasets: [{
                data: [1],
                backgroundColor: ['#e2e8f0'],
                borderColor: '#fff',
                borderWidth: 2,
                hoverOffset: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '64%',
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { boxWidth: 8, usePointStyle: true, padding: 12, font: { size: 11 } }
                },
                tooltip: {
                    callbacks: { label: ctx => `${ctx.label}：${ctx.parsed}` }
                }
            }
        }
    });
}

function buildOrderTrend(months) {
    const now = new Date();
    const rows = [];
    for (let i = months - 1; i >= 0; i--) {
        const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
        const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
        rows.push({ key, label: `${d.getMonth() + 1}月`, inbound: 0, outbound: 0 });
    }
    const byKey = new Map(rows.map(r => [r.key, r]));
    const add = (list, timeKey, qtyKey) => {
        (list || []).forEach(item => {
            const raw = item[timeKey];
            if (!raw) return;
            const d = new Date(raw);
            if (isNaN(d.getTime())) return;
            const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
            const row = byKey.get(key);
            if (row) row[qtyKey] += item.quantity || 0;
        });
    };
    add(state.inbound.list, 'inboundTime', 'inbound');
    add(state.outbound.list, 'outboundTime', 'outbound');
    return rows;
}

function renderStats() {
    if (!document.getElementById('statsView')?.classList.contains('active')) return;

    const goods = visibleGoods();
    const isWarehouse = currentUser?.role === 'WAREHOUSE';
    const trend = isWarehouse ? buildOrderTrend(6) : (dashboardTrend || []);
    const totalStock = goods.reduce((sum, g) => sum + (g.currentStock || 0), 0);
    const lowGoods = goods
        .filter(g => (g.currentStock ?? 0) < (g.minStock ?? 0))
        .sort((a, b) => ((b.minStock - b.currentStock) - (a.minStock - a.currentStock)));
    const current = trend[trend.length - 1] || { inbound: 0, outbound: 0 };
    const net = (current.inbound || 0) - (current.outbound || 0);

    setText('statsTotalStock', totalStock);
    setText('statsTotalGoods', goods.length);
    setText('statsLowStock', lowGoods.length);
    setText('statsStockScope', isWarehouse ? '本仓库存' : '全仓库存');
    setText('statsChartScope', isWarehouse ? '本仓' : '全仓');
    setText('statsTrendScope', `近 6 个月 · ${isWarehouse ? '本仓' : '全公司'}`);
    setText('statsNetHint', `本月入库 ${current.inbound || 0} - 出库 ${current.outbound || 0}`);

    const netEl = document.getElementById('statsNetChange');
    if (netEl) {
        netEl.textContent = `${net > 0 ? '+' : ''}${net}`;
        netEl.style.color = net >= 0 ? 'var(--color-success)' : 'var(--color-danger)';
    }

    if (statsChart) {
        statsChart.data.labels = [isWarehouse ? '本仓库存' : '总库存', '本月入库', '本月出库'];
        statsChart.data.datasets[0].data = [totalStock, current.inbound || 0, current.outbound || 0];
        statsChart.update();
    }

    renderStatsMonths(trend);
    renderStatsDimension('statsWarehouseBody', groupStats(goods, g => g.warehouse), totalStock);
    renderStatsDimension('statsCategoryBody', groupStats(goods, g => g.category || '未分类'), totalStock);
    renderStatsTop(goods);
    renderStatsLow(lowGoods);
}

function groupStats(goods, keyFn) {
    const map = new Map();
    goods.forEach(g => {
        const key = keyFn(g) || '未分类';
        const row = map.get(key) || { name: key, sku: 0, stock: 0, low: 0 };
        row.sku += 1;
        row.stock += g.currentStock || 0;
        if ((g.currentStock ?? 0) < (g.minStock ?? 0)) row.low += 1;
        map.set(key, row);
    });
    return map;
}

function renderStatsDimension(tbodyId, groups, totalStock) {
    const tbody = document.getElementById(tbodyId);
    if (!tbody) return;
    const rows = [...groups.values()].sort((a, b) => b.stock - a.stock);
    if (!rows.length) {
        tbody.innerHTML = statsEmptyRow(5, '暂无数据');
        return;
    }
    tbody.innerHTML = rows.map(r => `<tr>
        <td>${escapeHtml(r.name)}</td>
        <td>${r.sku}</td>
        <td>${r.stock}</td>
        <td>${totalStock > 0 ? ((r.stock / totalStock) * 100).toFixed(1) + '%' : '—'}</td>
        <td>${r.low}</td>
    </tr>`).join('');
}

function renderStatsMonths(trend) {
    const tbody = document.getElementById('statsMonthBody');
    if (!tbody) return;
    if (!trend || !trend.length) {
        tbody.innerHTML = statsEmptyRow(5, '暂无月度数据');
        return;
    }
    tbody.innerHTML = trend.map(row => {
        const net = (row.inbound || 0) - (row.outbound || 0);
        const ratio = (row.inbound || 0) > 0
            ? ((row.outbound || 0) / row.inbound * 100).toFixed(1) + '%'
            : '—';
        return `<tr>
            <td>${escapeHtml(row.label)}</td>
            <td>${row.inbound || 0}</td>
            <td>${row.outbound || 0}</td>
            <td>${net > 0 ? '+' : ''}${net}</td>
            <td>${ratio}</td>
        </tr>`;
    }).join('');

    const totalIn = trend.reduce((sum, row) => sum + (row.inbound || 0), 0);
    const totalOut = trend.reduce((sum, row) => sum + (row.outbound || 0), 0);
    const totalNet = totalIn - totalOut;
    const totalRatio = totalIn > 0 ? (totalOut / totalIn * 100).toFixed(1) + '%' : '—';
    tbody.innerHTML += `<tr class="total-row">
        <td>合计</td>
        <td>${totalIn}</td>
        <td>${totalOut}</td>
        <td>${totalNet > 0 ? '+' : ''}${totalNet}</td>
        <td>${totalRatio}</td>
    </tr>`;
}

function renderStatsTop(goods) {
    const tbody = document.getElementById('statsTopBody');
    if (!tbody) return;
    const top = [...goods]
        .sort((a, b) => (b.currentStock || 0) - (a.currentStock || 0))
        .slice(0, 10);
    if (!top.length) {
        tbody.innerHTML = statsEmptyRow(7, '暂无商品数据');
        return;
    }
    tbody.innerHTML = top.map((g, i) => `<tr>
        <td>${i + 1}</td>
        <td>${escapeHtml(g.code)}</td>
        <td>${escapeHtml(g.name)}</td>
        <td>${escapeHtml(g.category || '未分类')}</td>
        <td>${escapeHtml(g.warehouse)}</td>
        <td>${g.currentStock ?? 0}</td>
        <td>${stockStatusBadge(g)}</td>
    </tr>`).join('');
}

function stockStatusBadge(g) {
    const current = g.currentStock ?? 0;
    if (current < (g.minStock ?? 0)) return '<span class="badge bg-warning">低库存</span>';
    if (current > (g.maxStock ?? 0)) return '<span class="badge bg-warning">高库存</span>';
    return '<span class="badge bg-success">正常</span>';
}

function renderStatsLow(lowGoods) {
    const tbody = document.getElementById('statsLowBody');
    const badge = document.getElementById('statsLowCount');
    if (badge) badge.textContent = `${lowGoods.length} 项`;
    if (!tbody) return;
    if (!lowGoods.length) {
        tbody.innerHTML = statsEmptyRow(6, '库存健康，暂无低库存商品');
        return;
    }
    tbody.innerHTML = lowGoods.map(g => `<tr>
        <td>${escapeHtml(g.code)}</td>
        <td>${escapeHtml(g.name)}</td>
        <td>${escapeHtml(g.warehouse)}</td>
        <td>${g.currentStock ?? 0}</td>
        <td>${g.minStock ?? 0}</td>
        <td>${(g.minStock ?? 0) - (g.currentStock ?? 0)}</td>
    </tr>`).join('');
}

function statsEmptyRow(cols, text) {
    return `<tr><td colspan="${cols}" class="state-cell"><div class="state"><p>${escapeHtml(text)}</p></div></td></tr>`;
}

/* ---------------- 视图与初始化 ---------------- */

function targetLabel(type) {
    const map = {
        goods: '商品',
        inbound_order: '入库单',
        outbound_order: '出库单',
        warning: '预警',
        user: '用户',
        session: '会话'
    };
    return map[type] || type || '—';
}

async function loadLogs() {
    if (!isAdmin) return;
    const tbody = document.getElementById('logTableBody');
    if (tbody) tbody.innerHTML = loadingRow(8);
    try {
        state.log.list = await api('/api/logs');
        populateLogActions();
        renderLogs();
    } catch (e) {
        if (tbody) tbody.innerHTML = errorRow(8, 'loadLogs');
    }
}

function populateLogActions() {
    const select = document.getElementById('logActionFilter');
    if (!select) return;
    const current = select.value;
    const actions = [...new Set(state.log.list.map(l => l.action).filter(Boolean))].sort();
    select.innerHTML = '<option value="">全部动作</option>'
        + actions.map(a => `<option value="${escapeHtml(a)}">${escapeHtml(a)}</option>`).join('');
    if (actions.includes(current)) select.value = current;
}

function filteredLogs() {
    const q = (document.getElementById('logSearch')?.value || '').trim().toLowerCase();
    const action = document.getElementById('logActionFilter')?.value || '';
    return state.log.list.filter(l => {
        const matchText = !q
            || (l.username || '').toLowerCase().includes(q)
            || (l.action || '').toLowerCase().includes(q)
            || (l.detail || '').toLowerCase().includes(q)
            || (l.warehouse || '').toLowerCase().includes(q);
        const matchAction = !action || l.action === action;
        return matchText && matchAction;
    });
}

function renderLogs() {
    const tbody = document.getElementById('logTableBody');
    if (!tbody) return;
    const list = filteredLogs();
    const rows = pageSlice('log', list);
    if (!rows.length) {
        tbody.innerHTML = emptyRow(8, state.log.list.length ? '没有匹配的日志' : '暂无操作日志', '');
    } else {
        tbody.innerHTML = rows.map(l => `<tr>
            <td>${formatTime(l.createTime)}</td>
            <td>${escapeHtml(l.username || '—')}</td>
            <td>${roleLabel(l.role)}</td>
            <td>${escapeHtml(l.action || '—')}</td>
            <td>${escapeHtml(targetLabel(l.targetType))}${l.targetId ? ' #' + l.targetId : ''}</td>
            <td class="log-detail" title="${escapeHtml(l.detail || '')}">${escapeHtml(l.detail || '—')}</td>
            <td>${escapeHtml(l.warehouse || '—')}</td>
            <td>${escapeHtml(l.ip || '—')}</td>
        </tr>`).join('');
    }
    updatePager('log', list.length);
}

function exportLogs() {
    const list = filteredLogs();
    downloadCsv(`操作日志-${dateStamp()}.csv`,
        ['时间', '用户', '角色', '动作', '对象', '详情', '仓库', 'IP'],
        list.map(l => [formatTime(l.createTime), l.username, roleLabel(l.role), l.action,
            targetLabel(l.targetType) + (l.targetId ? ' #' + l.targetId : ''),
            l.detail, l.warehouse, l.ip]));
    toast(`已导出 ${list.length} 条日志`);
}

function switchView(viewId, title) {
    document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
    document.getElementById(viewId)?.classList.add('active');
    document.querySelectorAll('.nav-item[data-view]').forEach(n => n.classList.toggle('active', n.dataset.view === viewId));
    setText('pageTitle', title);
    document.body.classList.remove('sidebar-open');
    if (viewId === 'dashboardView') {
        requestAnimationFrame(resizeDashboardCharts);
    }
}

async function startApp() {
    applyCurrentUser();
    applyPermissions();
    if (!appStarted) {
        appStarted = true;
        initCharts();
    }
    const tasks = [loadDashboard(), loadWarnings(), loadGoods(), loadInbounds(), loadOutbounds()];
    if (isAdmin) tasks.push(loadUsers());
    await Promise.all(tasks);
}

function bindEvents() {
    document.getElementById('loginBtn')?.addEventListener('click', doLogin);
    document.getElementById('loginPassword')?.addEventListener('keydown', e => {
        if (e.key === 'Enter') doLogin();
    });

    document.getElementById('sidebarToggle')?.addEventListener('click', () => document.body.classList.add('sidebar-open'));
    document.getElementById('sidebarBackdrop')?.addEventListener('click', () => document.body.classList.remove('sidebar-open'));

    document.querySelectorAll('.nav-item[data-view]').forEach(item => {
        item.addEventListener('click', async () => {
            const view = item.dataset.view;
            if (view === 'userView' && !isAdmin) return;
            if (view === 'logView' && !isAdmin) return;
            if (view === 'statsView' && currentUser?.role === 'WAREHOUSE') return;
            switchView(view, item.dataset.title);
            if (view === 'dashboardView') await Promise.all([loadDashboard(), loadWarnings()]);
            if (view === 'warningView') { await loadWarnings(); renderWarningView(); }
            if (view === 'goodsView') await loadGoods();
            if (view === 'inboundView') await loadInbounds();
            if (view === 'outboundView') await loadOutbounds();
            if (view === 'userView' && isAdmin) await loadUsers();
            if (view === 'statsView') {
                await Promise.all([loadGoods(), loadWarnings(), loadInbounds(), loadOutbounds(), loadDashboard()]);
                renderStats();
            }
            if (view === 'logView') await loadLogs();
        });
    });

    document.getElementById('manualCheckBtn')?.addEventListener('click', manualCheck);
    document.getElementById('manualCheckBtn2')?.addEventListener('click', manualCheck);

    document.getElementById('addGoodsBtn')?.addEventListener('click', openAddGoods);
    document.getElementById('saveGoodsBtn')?.addEventListener('click', saveGoods);
    document.getElementById('confirmAddUserBtn')?.addEventListener('click', submitUser);
    document.getElementById('confirmBindBtn')?.addEventListener('click', submitBindWarehouse);

    document.getElementById('userInfoPasswordBtn')?.addEventListener('click', () => {
        const el = document.getElementById('userInfoModal');
        el.addEventListener('hidden.bs.modal', openChangePassword, { once: true });
        bootstrap.Modal.getInstance(el)?.hide();
    });
    document.getElementById('userInfoLogoutBtn')?.addEventListener('click', () => {
        const el = document.getElementById('userInfoModal');
        el.addEventListener('hidden.bs.modal', logout, { once: true });
        bootstrap.Modal.getInstance(el)?.hide();
    });
    document.querySelectorAll('input[name="userRole"]').forEach(input => {
        input.addEventListener('change', syncUserWarehouseField);
    });
    document.getElementById('addUserModal')?.addEventListener('show.bs.modal', () => {
        document.getElementById('userName').value = '';
        document.querySelector('input[name="userRole"][value="WAREHOUSE"]').checked = true;
        fillWarehouseOptions('userWarehouse', '');
        syncUserWarehouseField();
        document.getElementById('userError').textContent = '';
    });
    document.getElementById('confirmInboundBtn')?.addEventListener('click', submitInbound);
    document.getElementById('confirmOutboundBtn')?.addEventListener('click', submitOutbound);
    document.getElementById('savePasswordBtn')?.addEventListener('click', submitChangePassword);
    document.getElementById('confirmResetPasswordBtn')?.addEventListener('click', submitResetPassword);

    document.getElementById('confirmOk')?.addEventListener('click', () => {
        const resolve = confirmResolver;
        confirmResolver = null;
        bootstrap.Modal.getInstance(document.getElementById('confirmDialog'))?.hide();
        if (resolve) resolve(true);
    });
    document.getElementById('confirmDialog')?.addEventListener('hidden.bs.modal', () => {
        if (confirmResolver) {
            const resolve = confirmResolver;
            confirmResolver = null;
            resolve(false);
        }
    });

    bindFilter('goodsSearch', 'goods', renderGoods);
    bindFilter('inboundSearch', 'inbound', renderInbounds);
    bindFilter('outboundSearch', 'outbound', renderOutbounds);
    bindFilter('userSearch', 'user', renderUsers);
    bindFilter('logSearch', 'log', renderLogs);

    document.getElementById('goodsWarehouseFilter')?.addEventListener('change', () => {
        state.goods.page = 1;
        renderGoods();
    });

    document.getElementById('goodsCategoryFilter')?.addEventListener('change', () => {
        state.goods.page = 1;
        renderGoods();
    });

    document.getElementById('goodsExport')?.addEventListener('click', exportGoods);
    document.getElementById('inboundExport')?.addEventListener('click', exportInbounds);
    document.getElementById('outboundExport')?.addEventListener('click', exportOutbounds);

    document.querySelectorAll('input[name="warningType"], input[name="warningStatus"]').forEach(input => {
        input.addEventListener('change', () => {
            state.warning.page = 1;
            renderWarningView();
        });
    });

    bindPager('goods', renderGoods);
    bindPager('warning', renderWarningView);
    bindPager('inbound', renderInbounds);
    bindPager('outbound', renderOutbounds);
    bindPager('user', renderUsers);
    bindPager('log', renderLogs);

    document.getElementById('goodsRefresh')?.addEventListener('click', loadGoods);
    document.getElementById('warningRefresh')?.addEventListener('click', () => loadWarnings().then(renderWarningView));
    document.getElementById('inboundRefresh')?.addEventListener('click', loadInbounds);
    document.getElementById('outboundRefresh')?.addEventListener('click', loadOutbounds);
    document.getElementById('userRefresh')?.addEventListener('click', loadUsers);
    document.getElementById('logRefresh')?.addEventListener('click', loadLogs);
    document.getElementById('logExport')?.addEventListener('click', exportLogs);
    document.getElementById('logActionFilter')?.addEventListener('change', () => {
        state.log.page = 1;
        renderLogs();
    });

    document.getElementById('addInboundModal')?.addEventListener('show.bs.modal', () => {
        fillGoodsSelect('inboundGoodsId');
    });
    document.getElementById('addOutboundModal')?.addEventListener('show.bs.modal', () => {
        fillGoodsSelect('outboundGoodsId');
    });
}

function bindFilter(inputId, key, render) {
    const el = document.getElementById(inputId);
    if (!el) return;
    el.addEventListener('input', () => {
        state[key].page = 1;
        render();
    });
}

function bindPager(key, render) {
    const prev = document.getElementById(key + 'Prev');
    const next = document.getElementById(key + 'Next');
    const size = document.getElementById(key + 'PageSize');

    prev?.addEventListener('click', () => {
        if (state[key].page > 1) {
            state[key].page -= 1;
            render();
        }
    });
    next?.addEventListener('click', () => {
        state[key].page += 1;
        render();
    });
    size?.addEventListener('change', () => {
        state[key].size = Number(size.value);
        state[key].page = 1;
        render();
    });
}

document.addEventListener('DOMContentLoaded', async () => {
    if (window.lucide) lucide.createIcons();
    const storedLoginAt = sessionStorage.getItem('loginAt');
    if (storedLoginAt) {
        const parsed = new Date(storedLoginAt);
        if (!isNaN(parsed.getTime())) sessionLoginAt = parsed;
    }
    bindEvents();

    if (await checkSession()) {
        hideLogin();
        await startApp();
    } else {
        showLogin();
    }
});
