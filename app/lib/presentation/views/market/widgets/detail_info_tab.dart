import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

/// 信息标签页
class DetailInfoTab extends StatefulWidget {
  final TickerData ticker;

  const DetailInfoTab({
    super.key,
    required this.ticker,
  });

  @override
  State<DetailInfoTab> createState() => _DetailInfoTabState();
}

class _DetailInfoTabState extends State<DetailInfoTab> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final symbol = widget.ticker.symbol.replaceAll('/', '');
    final baseCurrency = symbol.replaceAll('USDT', '').replaceAll('BTC', '').replaceAll('ETH', '');
    
    // 模拟数据（实际应该从API获取）
    final coinInfo = _getCoinInfo(baseCurrency);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部区域：Logo、名称、交易所
          _buildHeader(baseCurrency, coinInfo),
          
          const SizedBox(height: 16),
          
          // 免责声明
          _buildDisclaimer(),
          
          const SizedBox(height: 24),
          
          // 市场数据区块
          _buildMarketData(coinInfo),
          
          const SizedBox(height: 24),
          
          // 链接区块
          _buildLinks(coinInfo),
          
          const SizedBox(height: 24),
          
          // 介绍区块
          _buildDescription(coinInfo),
        ],
      ),
    );
  }

  Widget _buildHeader(String symbol, Map<String, dynamic> coinInfo) {
    return Row(
      children: [
        // Logo
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              symbol.isNotEmpty ? symbol.substring(0, 1) : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coinInfo['name'] ?? symbol,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // 交易所信息
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'BINANCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: '* 基础数据由 CMC 提供,仅供参考。此信息以"原样"呈现,不构成任何形式的陈述或保证。'),
          TextSpan(
            text: '风险声明',
            style: TextStyle(
              color: Colors.orange,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketData(Map<String, dynamic> coinInfo) {
    final marketCap = coinInfo['marketCap'] ?? 0.0;
    final fullyDilutedMarketCap = coinInfo['fullyDilutedMarketCap'] ?? 0.0;
    final marketCapDominance = coinInfo['marketCapDominance'] ?? 0.0;
    final volume24h = coinInfo['volume24h'] ?? 0.0;
    final volumeMarketCapRatio = coinInfo['volumeMarketCapRatio'] ?? 0.0;
    final circulatingSupply = coinInfo['circulatingSupply'] ?? 0.0;
    final maxSupply = coinInfo['maxSupply'] ?? 0.0;
    final totalSupply = coinInfo['totalSupply'] ?? 0.0;
    final launchDate = coinInfo['launchDate'] ?? '';
    final allTimeHigh = coinInfo['allTimeHigh'] ?? 0.0;
    final allTimeHighDate = coinInfo['allTimeHighDate'] ?? '';
    final allTimeLow = coinInfo['allTimeLow'] ?? 0.0;
    final allTimeLowDate = coinInfo['allTimeLowDate'] ?? '';
    
    final usdToCny = 7.08;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('排名', 'NO.${coinInfo['rank'] ?? 1}', isHighlight: true),
        _buildDataRow('市值', _formatCurrency(marketCap, usdToCny)),
        _buildDataRow('完全稀释市值', _formatCurrency(fullyDilutedMarketCap, usdToCny)),
        _buildDataRow('市场占有率', '${marketCapDominance.toStringAsFixed(4)}%'),
        _buildDataRow('成交量', _formatCurrency(volume24h, usdToCny)),
        _buildDataRow('成交量/市值', '${volumeMarketCapRatio.toStringAsFixed(2)}%'),
        _buildDataRow('流通数量', _formatSupply(circulatingSupply, coinInfo['symbol'] ?? '')),
        _buildDataRow('最大供给量', _formatSupply(maxSupply, coinInfo['symbol'] ?? '')),
        _buildDataRow('总量', _formatSupply(totalSupply, coinInfo['symbol'] ?? '')),
        _buildDataRow('发行日期', launchDate),
        _buildDataRow('历史最高价', '${_formatPrice(allTimeHigh, usdToCny)} ${allTimeHighDate.isNotEmpty ? allTimeHighDate : ''}'),
        _buildDataRow('历史最低价', '${_formatPrice(allTimeLow, usdToCny)} ${allTimeLowDate.isNotEmpty ? allTimeLowDate : ''}'),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isHighlight ? Colors.orange : Colors.black87,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinks(Map<String, dynamic> coinInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '链接',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (coinInfo['officialWebsite'] != null)
          _buildLinkRow('官方网址', coinInfo['officialWebsite'], () {
            _launchURL(coinInfo['officialWebsite']);
          }),
        if (coinInfo['whitepaper'] != null)
          _buildLinkRow('', '白皮书', () {
            _launchURL(coinInfo['whitepaper']);
          }),
        if (coinInfo['blockExplorer'] != null)
          _buildLinkRow('区块浏览器', coinInfo['blockExplorer'], () {
            _launchURL(coinInfo['blockExplorer']);
          }),
        if (coinInfo['report'] != null)
          _buildLinkRow('报告', coinInfo['report'], () {
            _launchURL(coinInfo['report']);
          }),
      ],
    );
  }

  Widget _buildLinkRow(String label, String linkText, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                linkText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic> coinInfo) {
    final description = coinInfo['description'] ?? '';
    
    // 检查是否为 HTML 内容
    final isHtml = _isHtmlContent(description);
    
    // 计算需要截断的位置
    String shortDescription = '';
    String remainingText = '';
    bool hasMore = false;
    
    if (isHtml) {
      // HTML 内容：解析后按段落截断
      final doc = html_parser.parse(description);
      final text = doc.body?.text ?? description;
      final paragraphs = text.split('\n').where((p) => p.trim().isNotEmpty).toList();
      
      if (paragraphs.length > 1) {
        shortDescription = paragraphs[0];
        remainingText = paragraphs.sublist(1).join('\n');
        hasMore = true;
      } else {
        final maxLength = 200;
        if (text.length > maxLength) {
          // 截断 HTML，需要找到合适的截断点
          shortDescription = _truncateHtml(description, maxLength);
          remainingText = description.substring(shortDescription.length);
          hasMore = true;
        } else {
          shortDescription = description;
        }
      }
    } else {
      // 纯文本内容
      final lines = description.split('\n');
      if (lines.length > 1) {
        shortDescription = lines[0];
        remainingText = lines.sublist(1).join('\n');
        hasMore = true;
      } else {
        final maxLength = 200;
        if (description.length > maxLength) {
          shortDescription = description.substring(0, maxLength);
          remainingText = description.substring(maxLength);
          hasMore = true;
        } else {
          shortDescription = description;
        }
      }
    }
    
    final displayText = _isDescriptionExpanded ? description : shortDescription;
    final showMore = hasMore && !_isDescriptionExpanded;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '介绍',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // 复制描述文本（去除 HTML 标签）
                    final plainText = isHtml 
                        ? (html_parser.parse(description).body?.text ?? description)
                        : description;
                    Clipboard.setData(ClipboardData(text: plainText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已复制到剪贴板'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Icon(
                      Icons.copy,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // TODO: 跳转到详情页面
              },
              child: const Text(
                '了解详情',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 内容文本（支持 HTML）
        isHtml
            ? Html(
                data: displayText + (showMore ? '...' : ''),
                style: {
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(14),
                    color: Colors.black87,
                    lineHeight: LineHeight(1.6),
                  ),
                  'p': Style(
                    margin: Margins.only(bottom: 8),
                  ),
                },
              )
            : Text(
                displayText + (showMore ? '...' : ''),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
        // 展开按钮
        if (hasMore) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isDescriptionExpanded ? '收起' : '展开',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 检查内容是否为 HTML
  bool _isHtmlContent(String text) {
    if (text.trim().isEmpty) return false;
    // 简单的 HTML 标签检测
    final htmlPattern = RegExp(r'<[a-z][\s\S]*>', caseSensitive: false);
    return htmlPattern.hasMatch(text);
  }

  /// 截断 HTML 内容（简单实现）
  String _truncateHtml(String html, int maxLength) {
    // 移除 HTML 标签计算纯文本长度
    final doc = html_parser.parse(html);
    final text = doc.body?.text ?? '';
    
    if (text.length <= maxLength) {
      return html;
    }
    
    // 简单截断：找到第一个段落结束位置
    final truncatedText = text.substring(0, maxLength);
    final firstParagraphEnd = html.indexOf('</p>');
    if (firstParagraphEnd > 0 && firstParagraphEnd < html.length) {
      return html.substring(0, firstParagraphEnd + 4);
    }
    
    // 如果找不到段落，返回前 maxLength 个字符
    return html.substring(0, maxLength);
  }

  Map<String, dynamic> _getCoinInfo(String symbol) {
    // 模拟数据，实际应该从API获取
    final coinData = {
      'BTC': {
        'name': 'Bitcoin',
        'rank': 1,
        'marketCap': 1870000000000.0, // $1.87兆
        'fullyDilutedMarketCap': 1970000000000.0, // $1.97兆
        'marketCapDominance': 59.2922,
        'volume24h': 82911000000.0, // $829.11亿
        'volumeMarketCapRatio': 4.44,
        'circulatingSupply': 19957000.0, // 1995.7万
        'maxSupply': 21000000.0, // 2100万
        'totalSupply': 19957000.0, // 1995.7万
        'symbol': 'BTC',
        'launchDate': '2009-01-03',
        'allTimeHigh': 126198.0696,
        'allTimeHighDate': '2025-10-07',
        'allTimeLow': 0.04864654,
        'allTimeLowDate': '2010-07-15',
        'officialWebsite': 'https://bitcoin.org',
        'whitepaper': 'https://bitcoin.org/bitcoin.pdf',
        'blockExplorer': 'https://blockchain.info',
        'report': 'https://example.com/report',
        'description': '比特币(BTC)是一种点对点加密货币,旨在充当独立于任何中央机构的一种交易手段。BTC可以安全,可验证和不变的方式进行电子现金转移。\nBTC于2009年推出,是通过在交易信息广播到比特币网络中的所有节点之前加盖交易时间戳的"第一种解决双重支出问题的虚拟数字货币"。比特币协议通过blockchain网络结构为拜占庭容错问题提供了解决方案,该概念最初由Stuart Haber和W. Scott Stornetta创建1991年。比特币网络通过工作量证明(PoW)共识机制来验证和记录交易,确保网络的安全性和去中心化特性。',
      },
      'ETH': {
        'name': 'Ethereum',
        'rank': 2,
        'marketCap': 500000000000.0,
        'fullyDilutedMarketCap': 600000000000.0,
        'marketCapDominance': 20.0,
        'volume24h': 20000000000.0,
        'volumeMarketCapRatio': 4.0,
        'circulatingSupply': 120000000.0,
        'maxSupply': 0.0,
        'totalSupply': 120000000.0,
        'symbol': 'ETH',
        'launchDate': '2015-07-30',
        'allTimeHigh': 4878.0,
        'allTimeHighDate': '2021-11-10',
        'allTimeLow': 0.42,
        'allTimeLowDate': '2015-10-20',
        'officialWebsite': 'https://ethereum.org',
        'whitepaper': 'https://ethereum.org/whitepaper',
        'blockExplorer': 'https://etherscan.io',
        'report': 'https://example.com/report',
        'description': '以太坊(ETH)是一个去中心化的开源区块链系统,具有智能合约功能。以太币是以太坊网络的原生加密货币。',
      },
    };
    
    return coinData[symbol] ?? {
      'name': symbol,
      'rank': 999,
      'marketCap': 0.0,
      'fullyDilutedMarketCap': 0.0,
      'marketCapDominance': 0.0,
      'volume24h': 0.0,
      'volumeMarketCapRatio': 0.0,
      'circulatingSupply': 0.0,
      'maxSupply': 0.0,
      'totalSupply': 0.0,
      'symbol': symbol,
      'launchDate': '',
      'allTimeHigh': 0.0,
      'allTimeHighDate': '',
      'allTimeLow': 0.0,
      'allTimeLowDate': '',
      'description': '暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍暂无介绍',
    };
  }

  String _formatCurrency(double value, double usdToCny) {
    if (value >= 1000000000000) {
      return '\$${(value / 1000000000000).toStringAsFixed(2)}兆 ≈ ¥${(value * usdToCny / 1000000000000).toStringAsFixed(2)}兆';
    } else if (value >= 100000000) {
      return '\$${(value / 100000000).toStringAsFixed(2)}亿 ≈ ¥${(value * usdToCny / 100000000).toStringAsFixed(2)}亿';
    } else if (value >= 10000) {
      return '\$${(value / 10000).toStringAsFixed(2)}万 ≈ ¥${(value * usdToCny / 10000).toStringAsFixed(2)}万';
    } else {
      return '\$${value.toStringAsFixed(2)} ≈ ¥${(value * usdToCny).toStringAsFixed(2)}';
    }
  }

  String _formatPrice(double value, double usdToCny) {
    if (value >= 1000) {
      return '\$${value.toStringAsFixed(4)} ≈ ¥${(value * usdToCny).toStringAsFixed(4)}';
    } else {
      return '\$${value.toStringAsFixed(8)} ≈ ¥${(value * usdToCny).toStringAsFixed(8)}';
    }
  }

  String _formatSupply(double value, String symbol) {
    if (value >= 100000000) {
      return '${(value / 100000000).toStringAsFixed(1)}亿 $symbol';
    } else if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}万 $symbol';
    } else {
      return '${value.toStringAsFixed(2)} $symbol';
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
