package com.warehouse.service;

import com.warehouse.entity.Goods;
import com.warehouse.entity.WarningRecord;
import com.warehouse.repository.GoodsRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 仓库隔离与预警口径：
 * 商品列表必须由后端按仓库收敛；预警重算不能堆重复行；未处理计数要排除已处理。
 */
@SpringBootTest
@Transactional
class WarehouseIsolationTests {

    @Autowired private GoodsService goodsService;
    @Autowired private WarningService warningService;
    @Autowired private GoodsRepository goodsRepository;

    private Goods goods(String code, String warehouse, int stock, int min, int max) {
        Goods goods = new Goods();
        goods.setCode(code);
        goods.setName("隔离测试-" + code);
        goods.setWarehouse(warehouse);
        goods.setCurrentStock(stock);
        goods.setMinStock(min);
        goods.setMaxStock(max);
        goods.setCreateTime(LocalDateTime.now());
        return goodsRepository.save(goods);
    }

    @Test
    void goodsListFollowsWarehouseScope() {
        goods("W-A-1", "甲仓", 5, 1, 10);
        goods("W-B-1", "乙仓", 5, 1, 10);

        assertThat(goodsService.getGoods(null))
                .extracting(Goods::getCode)
                .contains("W-A-1", "W-B-1");
        assertThat(goodsService.getGoods("甲仓"))
                .extracting(Goods::getCode)
                .containsExactly("W-A-1");
        assertThat(goodsService.getGoods("")).isEmpty();
    }

    @Test
    void manualCheckKeepsOneRecordPerGoodsAndType() {
        goods("W-C-1", "甲仓", 0, 5, 20);

        warningService.manualCheckWarnings("甲仓");
        List<WarningRecord> first = warningService.getWarnings("甲仓");
        assertThat(first).hasSize(1);

        warningService.processWarning(first.get(0).getId(), "甲仓");
        warningService.manualCheckWarnings("甲仓");

        List<WarningRecord> second = warningService.getWarnings("甲仓");
        assertThat(second).hasSize(1);
        assertThat(second.get(0).getStatus()).isEqualTo("未处理");
    }

    @Test
    void pendingCountIgnoresProcessedAndOtherWarehouses() {
        goods("W-D-1", "甲仓", 0, 5, 20);
        goods("W-D-2", "甲仓", 30, 5, 20);

        warningService.manualCheckWarnings("甲仓");
        assertThat(warningService.countPendingWarnings("甲仓")).isEqualTo(2);
        assertThat(warningService.countAllWarnings("甲仓")).isEqualTo(2);

        Long id = warningService.getWarnings("甲仓").get(0).getId();
        warningService.processWarning(id, "甲仓");

        assertThat(warningService.countPendingWarnings("甲仓")).isEqualTo(1);
        assertThat(warningService.countAllWarnings("甲仓")).isEqualTo(2);
        assertThat(warningService.countPendingWarnings("乙仓")).isZero();
        assertThat(warningService.countPendingWarnings("")).isZero();
    }
}
