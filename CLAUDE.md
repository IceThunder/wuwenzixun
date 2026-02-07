# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

wuwenzixun 是一个企业风险分析助手，通过 Bash 脚本实时抓取企业信息，生成综合风险分析和未来展望报告。

## 常用命令

```bash
# 运行完整分析流程
./analyze.sh "公司名称"

# 指定分析深度
./analyze.sh "公司名称" --depth quick|normal|full

# 单独运行子技能
cd news && ./fetch.sh "公司名称"
cd risk && ./check.sh "公司名称"
cd finance && ./fetch.sh "公司名称"
cd report && ./generate.sh "公司名称"
cd outlook && ./predict.sh "公司名称"

# 安装 Python 可选依赖
pip install -r requirements.txt
```

## 架构

项目采用管道式模块化架构，由 `analyze.sh` 作为统一入口，按顺序调用 5 个独立子技能模块：

```
news/fetch.sh → risk/check.sh → finance/fetch.sh → report/generate.sh → outlook/predict.sh
```

每个子技能模块包含：
- `SKILL.md` - 该模块的详细功能文档
- 一个可独立运行的 `.sh` 脚本

全局配置集中在 `config.sh`，包含分析深度、行业领域、风险权重、输出格式、缓存目录等参数。

## 技术栈

- **主要语言**: Bash 4.0+
- **核心依赖**: curl（HTTP 请求）、jq（JSON 处理）
- **可选**: Python 3 + requirements.txt 中的库（高级分析）

## 风险评分体系

综合评分 = 财务风险(30%) + 运营风险(25%) + 法律风险(20%) + 市场风险(15%) + 声誉风险(10%)，权重在 `config.sh` 的 `WEIGHTS` 数组中配置。

## 开发约定

- 所有脚本使用中文输出
- 各子技能脚本必须支持独立运行，接收公司名称作为第一个参数
- 缓存目录为 `~/.cache/wuwenzixun/`
- 默认输出格式为 Markdown
