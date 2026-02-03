# wuwenzixun - 企业风险分析助手

实时抓取指定企业的网上信息，生成企业风险分析和未来展望报告。

## 项目结构

```
wuwenzixun/
├── news/          # 企业新闻抓取
│   └── fetch.sh   # 新闻获取脚本
├── risk/          # 风险信息检索
│   └── check.sh   # 风险检查脚本
├── finance/       # 财务信息抓取
│   └── fetch.sh   # 财务获取脚本
├── report/        # 风险分析报告
│   └── generate.sh # 报告生成脚本
├── outlook/       # 未来展望建议
│   └── predict.sh  # 预测脚本
└── SKILL.md       # 主技能文档
```

## 使用方法

```bash
# 完整分析流程
cd news && ./fetch.sh "公司名称"
cd ../risk && ./check.sh "公司名称"
cd ../finance && ./fetch.sh "公司名称"
cd ../report && ./generate.sh "公司名称"
cd ../outlook && ./predict.sh "公司名称"

# 或使用快捷脚本
./analyze.sh "公司名称"
```

## 子技能

1. **news** - 抓取企业最新新闻资讯
2. **risk** - 检索企业风险信息
3. **finance** - 抓取企业财务数据
4. **report** - 生成综合风险报告
5. **outlook** - 提供未来展望建议

## 环境要求

- curl / wget
- bash 4.0+
- jq (JSON处理，可选)
- Python 3.x (可选，用于高级分析)

## 配置

在 `config.sh` 中设置：
- 分析深度级别
- 关注的风险领域
- 输出格式偏好
