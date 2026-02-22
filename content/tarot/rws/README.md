# 韦特塔罗（RWS）牌组内容

公版韦特塔罗（Rider-Waite-Smith，1909）78 张全卡组列表与示例释义数据，释义参考公域资料（如 Waite《The Pictorial Key to the Tarot》及常见解读）。

## 文件说明

| 文件 | 说明 |
|------|------|
| **card_list.json** | 78 张牌列表：`cardId`（rws_00～rws_77）、`cardNameZh`（中文名）、`cardNameEn`（英文名）。大阿尔卡纳 0–21，小阿尔卡纳权杖 22–35、圣杯 36–49、宝剑 50–63、星币 64–77。 |
| **sample_cards.json** | 示例牌数据（至少 3 张）：`cardId`、`cardName`、`uprightMeaning`、`reversedMeaning`。用于规格验收与生成 `assets/tarot/rws.json` 时参考。 |

## cardId 与牌序

- **rws_00～rws_21**：大阿尔卡纳（愚者～世界）
- **rws_22～rws_35**：权杖（王牌、二～十、侍者、骑士、王后、国王）
- **rws_36～rws_49**：圣杯（同上）
- **rws_50～rws_63**：宝剑（同上）
- **rws_64～rws_77**：星币（同上）

应用内牌组数据路径见 [simple_divination_spec](../../../docs/technical/simple_divination_spec.md)：`assets/tarot/rws.json`。
