-- smart-warehouse 追加演示数据（2026-11-01）
-- 新增 20 个 SKU、20 入 / 20 出、5 个用户；库存与月统计保持自洽
USE smart_warehouse;

-- ---------- 商品 ----------
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (11, 'G011', '小米 14 手机', '中心仓库', 8, 5, 40, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (12, 'G012', '华为 MatePad', '中心仓库', 5, 8, 30, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (13, 'G013', 'Type-C 数据线', '中心仓库', 220, 50, 500, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (14, 'G014', '65W 氮化镓充电器', '中心仓库', 110, 30, 300, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (15, 'G015', '蓝牙音箱', '二号仓', 65, 20, 150, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (16, 'G016', '智能手环', '二号仓', 62, 15, 120, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (17, 'G017', '4K 摄像头', '二号仓', 38, 10, 30, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (18, 'G018', '路由器 AX3000', '二号仓', 35, 10, 100, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (19, 'G019', '移动硬盘 1TB', '中心仓库', 32, 10, 80, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (20, 'G020', 'U 盘 128G', '中心仓库', 180, 30, 300, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (21, 'G021', '一次性雨衣', '退货仓', 900, 100, 2000, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (22, 'G022', '泡沫填充物', '退货仓', 480, 50, 1000, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (23, 'G023', '缠绕膜', '退货仓', 420, 40, 800, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (24, 'G024', '冷链冰袋', '冷链仓', 740, 100, 1500, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (25, 'G025', '保温泡沫箱', '冷链仓', 110, 20, 200, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (26, 'G026', '温度记录仪', '冷链仓', 35, 40, 60, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (27, 'G027', '电子秤', '二号仓', 24, 5, 50, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (28, 'G028', '封箱胶带', '中心仓库', 1100, 100, 2000, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (29, 'G029', '快递面单纸', '中心仓库', 650, 50, 1000, '2026-10-30 10:00:00', '2026-11-01 18:00:00');
INSERT IGNORE INTO goods (id, code, name, warehouse, current_stock, min_stock, max_stock, create_time, update_time) VALUES (30, 'G030', '手持终端 PDA', '二号仓', 21, 5, 40, '2026-10-30 10:00:00', '2026-11-01 18:00:00');

-- ---------- 入库单 / 流水 ----------
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (101, 'IN-20261101-011', 11, '小米 14 手机', 30, '2026-11-01 00:00:00', '王强');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (101, 11, 30, '2026-11-01 00:00:00', '王强');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (102, 'IN-20261101-012', 12, '华为 MatePad', 20, '2026-11-01 00:00:00', '赵敏');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (102, 12, 20, '2026-11-01 00:00:00', '赵敏');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (103, 'IN-20261101-013', 13, 'Type-C 数据线', 400, '2026-11-01 00:00:00', '刘洋');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (103, 13, 400, '2026-11-01 00:00:00', '刘洋');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (104, 'IN-20261101-014', 14, '65W 氮化镓充电器', 200, '2026-11-01 00:00:00', '陈静');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (104, 14, 200, '2026-11-01 00:00:00', '陈静');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (105, 'IN-20261101-015', 15, '蓝牙音箱', 100, '2026-11-01 00:05:00', '孙磊');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (105, 15, 100, '2026-11-01 00:05:00', '孙磊');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (106, 'IN-20261101-016', 16, '智能手环', 80, '2026-11-01 00:05:00', '王强');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (106, 16, 80, '2026-11-01 00:05:00', '王强');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (107, 'IN-20261101-017', 17, '4K 摄像头', 50, '2026-11-01 00:05:00', '赵敏');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (107, 17, 50, '2026-11-01 00:05:00', '赵敏');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (108, 'IN-20261101-018', 18, '路由器 AX3000', 60, '2026-11-01 00:05:00', '刘洋');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (108, 18, 60, '2026-11-01 00:05:00', '刘洋');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (109, 'IN-20261101-019', 19, '移动硬盘 1TB', 40, '2026-11-01 00:05:00', '陈静');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (109, 19, 40, '2026-11-01 00:05:00', '陈静');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (110, 'IN-20261101-020', 20, 'U 盘 128G', 250, '2026-11-01 00:10:00', '孙磊');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (110, 20, 250, '2026-11-01 00:10:00', '孙磊');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (111, 'IN-20261101-021', 21, '一次性雨衣', 1200, '2026-11-01 00:10:00', '王强');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (111, 21, 1200, '2026-11-01 00:10:00', '王强');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (112, 'IN-20261101-022', 22, '泡沫填充物', 600, '2026-11-01 00:10:00', '赵敏');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (112, 22, 600, '2026-11-01 00:10:00', '赵敏');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (113, 'IN-20261101-023', 23, '缠绕膜', 500, '2026-11-01 00:10:00', '刘洋');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (113, 23, 500, '2026-11-01 00:10:00', '刘洋');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (114, 'IN-20261101-024', 24, '冷链冰袋', 1000, '2026-11-01 00:10:00', '陈静');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (114, 24, 1000, '2026-11-01 00:10:00', '陈静');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (115, 'IN-20261101-025', 25, '保温泡沫箱', 150, '2026-11-01 00:10:00', '孙磊');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (115, 25, 150, '2026-11-01 00:10:00', '孙磊');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (116, 'IN-20261101-026', 26, '温度记录仪', 40, '2026-11-01 00:10:00', '王强');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (116, 26, 40, '2026-11-01 00:10:00', '王强');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (117, 'IN-20261101-027', 27, '电子秤', 30, '2026-11-01 00:15:00', '赵敏');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (117, 27, 30, '2026-11-01 00:15:00', '赵敏');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (118, 'IN-20261101-028', 28, '封箱胶带', 1500, '2026-11-01 00:15:00', '刘洋');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (118, 28, 1500, '2026-11-01 00:15:00', '刘洋');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (119, 'IN-20261101-029', 29, '快递面单纸', 800, '2026-11-01 00:15:00', '陈静');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (119, 29, 800, '2026-11-01 00:15:00', '陈静');
INSERT IGNORE INTO inbound_order (id, order_no, goods_id, goods_name, quantity, inbound_time, operator) VALUES (120, 'IN-20261101-030', 30, '手持终端 PDA', 25, '2026-11-01 00:15:00', '孙磊');
INSERT IGNORE INTO inbound_record (id, goods_id, quantity, in_time, operator) VALUES (120, 30, 25, '2026-11-01 00:15:00', '孙磊');

-- ---------- 出库单 / 流水 ----------
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (101, 'OUT-20261101-011', 11, '小米 14 手机', 22, '2026-11-01 00:20:00', '刘洋');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (101, 11, 22, '2026-11-01 00:20:00', '刘洋');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (102, 'OUT-20261101-012', 12, '华为 MatePad', 15, '2026-11-01 00:20:00', '陈静');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (102, 12, 15, '2026-11-01 00:20:00', '陈静');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (103, 'OUT-20261101-013', 13, 'Type-C 数据线', 180, '2026-11-01 00:20:00', '孙磊');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (103, 13, 180, '2026-11-01 00:20:00', '孙磊');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (104, 'OUT-20261101-014', 14, '65W 氮化镓充电器', 90, '2026-11-01 00:20:00', '王强');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (104, 14, 90, '2026-11-01 00:20:00', '王强');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (105, 'OUT-20261101-015', 15, '蓝牙音箱', 35, '2026-11-01 00:20:00', '赵敏');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (105, 15, 35, '2026-11-01 00:20:00', '赵敏');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (106, 'OUT-20261101-016', 16, '智能手环', 18, '2026-11-01 00:25:00', '刘洋');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (106, 16, 18, '2026-11-01 00:25:00', '刘洋');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (107, 'OUT-20261101-017', 17, '4K 摄像头', 12, '2026-11-01 00:25:00', '陈静');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (107, 17, 12, '2026-11-01 00:25:00', '陈静');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (108, 'OUT-20261101-018', 18, '路由器 AX3000', 25, '2026-11-01 00:25:00', '孙磊');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (108, 18, 25, '2026-11-01 00:25:00', '孙磊');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (109, 'OUT-20261101-019', 19, '移动硬盘 1TB', 8, '2026-11-01 00:25:00', '王强');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (109, 19, 8, '2026-11-01 00:25:00', '王强');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (110, 'OUT-20261101-020', 20, 'U 盘 128G', 70, '2026-11-01 00:25:00', '赵敏');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (110, 20, 70, '2026-11-01 00:25:00', '赵敏');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (111, 'OUT-20261101-021', 21, '一次性雨衣', 300, '2026-11-01 00:25:00', '刘洋');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (111, 21, 300, '2026-11-01 00:25:00', '刘洋');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (112, 'OUT-20261101-022', 22, '泡沫填充物', 120, '2026-11-01 00:25:00', '陈静');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (112, 22, 120, '2026-11-01 00:25:00', '陈静');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (113, 'OUT-20261101-023', 23, '缠绕膜', 80, '2026-11-01 00:30:00', '孙磊');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (113, 23, 80, '2026-11-01 00:30:00', '孙磊');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (114, 'OUT-20261101-024', 24, '冷链冰袋', 260, '2026-11-01 00:30:00', '王强');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (114, 24, 260, '2026-11-01 00:30:00', '王强');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (115, 'OUT-20261101-025', 25, '保温泡沫箱', 40, '2026-11-01 00:30:00', '赵敏');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (115, 25, 40, '2026-11-01 00:30:00', '赵敏');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (116, 'OUT-20261101-026', 26, '温度记录仪', 5, '2026-11-01 00:30:00', '刘洋');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (116, 26, 5, '2026-11-01 00:30:00', '刘洋');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (117, 'OUT-20261101-027', 27, '电子秤', 6, '2026-11-01 00:30:00', '陈静');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (117, 27, 6, '2026-11-01 00:30:00', '陈静');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (118, 'OUT-20261101-028', 28, '封箱胶带', 400, '2026-11-01 00:30:00', '孙磊');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (118, 28, 400, '2026-11-01 00:30:00', '孙磊');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (119, 'OUT-20261101-029', 29, '快递面单纸', 150, '2026-11-01 00:30:00', '王强');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (119, 29, 150, '2026-11-01 00:30:00', '王强');
INSERT IGNORE INTO outbound_order (id, order_no, goods_id, goods_name, quantity, outbound_time, operator) VALUES (120, 'OUT-20261101-030', 30, '手持终端 PDA', 4, '2026-11-01 00:30:00', '赵敏');
INSERT IGNORE INTO outbound_record (id, goods_id, quantity, out_time, operator) VALUES (120, 30, 4, '2026-11-01 00:30:00', '赵敏');

-- ---------- 2026-11 月统计 ----------
INSERT INTO monthly_stat (id, stat_month, inbound_total, outbound_total) VALUES (2, '2026-11', 7075, 1840) ON DUPLICATE KEY UPDATE inbound_total=VALUES(inbound_total), outbound_total=VALUES(outbound_total);

-- ---------- 用户（初始密码 123456，首次登录自动升级 BCrypt） ----------
INSERT IGNORE INTO sys_user (id, username, password, role, warehouse, create_time) VALUES (4, 'wangqiang', '123456', 'WAREHOUSE', '中心仓库', '2026-10-30 09:00:00');
INSERT IGNORE INTO sys_user (id, username, password, role, warehouse, create_time) VALUES (5, 'zhaomin', '123456', 'WAREHOUSE', '冷链仓', '2026-10-30 09:00:00');
INSERT IGNORE INTO sys_user (id, username, password, role, warehouse, create_time) VALUES (6, 'liuyang', '123456', 'WAREHOUSE', '退货仓', '2026-10-30 09:00:00');
INSERT IGNORE INTO sys_user (id, username, password, role, warehouse, create_time) VALUES (7, 'chenjing', '123456', 'ADMIN', NULL, '2026-10-30 09:00:00');
INSERT IGNORE INTO sys_user (id, username, password, role, warehouse, create_time) VALUES (8, 'sunlei', '123456', 'WAREHOUSE', '二号仓', '2026-10-30 09:00:00');
INSERT IGNORE INTO sys_user (id, username, password, role, warehouse, create_time) VALUES (9, 'guest', '123456', 'VIEWER', NULL, '2026-11-01 00:00:00');

-- ---------- 单据/流水回填仓库（需先启动一次应用，让 JPA 建出 warehouse 列） ----------
UPDATE inbound_order o JOIN goods g ON o.goods_id = g.id SET o.warehouse = g.warehouse WHERE o.warehouse IS NULL;
UPDATE inbound_record r JOIN goods g ON r.goods_id = g.id SET r.warehouse = g.warehouse WHERE r.warehouse IS NULL;
UPDATE outbound_order o JOIN goods g ON o.goods_id = g.id SET o.warehouse = g.warehouse WHERE o.warehouse IS NULL;
UPDATE outbound_record r JOIN goods g ON r.goods_id = g.id SET r.warehouse = g.warehouse WHERE r.warehouse IS NULL;

-- ---------- 历史月统计（供近 6 个月趋势图） ----------
INSERT IGNORE INTO monthly_stat (id, stat_month, inbound_total, outbound_total) VALUES
 (3, '2026-06', 520, 420),
 (4, '2026-07', 640, 700),
 (5, '2026-08', 710, 600),
 (6, '2026-09', 820, 970);

-- ---------- 商品分类回填 ----------
UPDATE goods SET category = CASE
 WHEN code IN ('G001','G002','G003','G004','G005','G006','G011','G012','G013','G014','G015','G016','G018','G019','G020') THEN '数码配件'
 WHEN code IN ('G008','G009','G017','G027','G030') THEN '仓储设备'
 WHEN code IN ('G010','G022','G023','G028','G029') THEN '包装耗材'
 WHEN code IN ('G007','G024','G025','G026') THEN '冷链物资'
 WHEN code IN ('G021') THEN '劳保用品'
 ELSE '其他' END
WHERE category IS NULL OR category = '';