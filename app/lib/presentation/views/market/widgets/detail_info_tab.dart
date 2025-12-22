import 'package:fastapp/constants/exchange_rate.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/domain/entity/market/currency_detail.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

/// 信息标签页
class DetailInfoTab extends StatefulWidget {
  final TickerData ticker;
  final CurrencyDetail? currencyDetail;

  const DetailInfoTab({
    super.key,
    required this.ticker,
    this.currencyDetail,
  });

  @override
  State<DetailInfoTab> createState() => _DetailInfoTabState();
}

class _DetailInfoTabState extends State<DetailInfoTab> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currencyDetail = widget.currencyDetail;
    
    if (currencyDetail == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部区域：Logo、名称、交易所
          _buildHeader(currencyDetail),
          
          const SizedBox(height: 16),
          
          // 免责声明
          _buildDisclaimer(),
          
          const SizedBox(height: 24),
          
          // 市场数据区块
          _buildMarketData(currencyDetail),
          
          const SizedBox(height: 24),
          
          // 链接区块
          _buildLinks(currencyDetail),
          
          const SizedBox(height: 24),
          
          // 介绍区块
          _buildDescription(currencyDetail),
        ],
      ),
    );
  }

  Widget _buildHeader(CurrencyDetail currencyDetail) {
    return Row(
      children: [
        // Logo
        _buildLogo(currencyDetail),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            currencyDetail.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(CurrencyDetail currencyDetail) {
    final logoUrl = ImageUtils.formatSingleImagePath(currencyDetail.logo);
    final fallbackText = currencyDetail.symbol.isNotEmpty
        ? currencyDetail.symbol.substring(0, 1)
        : '?';

    final logoWidget = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          fallbackText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    final hasLogo = currencyDetail.logo != null && 
                    currencyDetail.logo!.isNotEmpty && 
                    logoUrl != ImageUtils.defaultImage;

    if (!hasLogo) return logoWidget;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        logoUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => logoWidget,
      ),
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

  Widget _buildMarketData(CurrencyDetail currencyDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currencyDetail.marketCapRank != null)
          _buildDataRow('排名', 'NO.${currencyDetail.marketCapRank}', isHighlight: true),
        if (_hasValue(currencyDetail.marketCap))
          _buildDataRow('市值', _formatCurrency(_parseDouble(currencyDetail.marketCap), ExchangeRate.getUsdToCnySync())),
        if (_hasValue(currencyDetail.fullyDilutedMarketCap))
          _buildDataRow('完全稀释市值', _formatCurrency(_parseDouble(currencyDetail.fullyDilutedMarketCap), ExchangeRate.getUsdToCnySync())),
        if (_hasValue(currencyDetail.circulatingSupply))
          _buildDataRow('流通数量', _formatSupply(_parseDouble(currencyDetail.circulatingSupply), currencyDetail.symbol)),
        if (_hasValue(currencyDetail.maxSupply))
          _buildDataRow('最大供给量', _formatSupply(_parseDouble(currencyDetail.maxSupply), currencyDetail.symbol)),
        if (_hasValue(currencyDetail.totalSupply))
          _buildDataRow('总量', _formatSupply(_parseDouble(currencyDetail.totalSupply), currencyDetail.symbol)),
        if (_hasValue(currencyDetail.launchDate))
          _buildDataRow('发行日期', currencyDetail.launchDate!),
        if (_hasValue(currencyDetail.consensusAlgorithm))
          _buildDataRow('共识算法', currencyDetail.consensusAlgorithm!),
        if (_hasValue(currencyDetail.algorithm))
          _buildDataRow('算法', currencyDetail.algorithm!),
      ],
    );
  }

  bool _hasValue(String? value) => value != null && value.isNotEmpty;
  
  double _parseDouble(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
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

  Widget _buildLinks(CurrencyDetail currencyDetail) {
    final links = currencyDetail.links;
    
    final linkItems = [
      MapEntry('官网', links.website),
      MapEntry('白皮书', links.whitepaper),
      MapEntry('区块浏览器', links.explorer),
      MapEntry('GitHub', links.github),
      MapEntry('Twitter', links.twitter),
      MapEntry('Telegram', links.telegram),
      MapEntry('Discord', links.discord),
      MapEntry('Reddit', links.reddit),
      MapEntry('Medium', links.medium),
      MapEntry('YouTube', links.youtube),
      MapEntry('Facebook', links.facebook),
    ];
    
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
        ...linkItems.map((item) {
          final url = item.value;
          final hasUrl = url != null && url.isNotEmpty;
          return _buildLinkRow(
            item.key,
            hasUrl ? url! : '-',
            hasUrl ? () => _launchURL(url!) : null,
          );
        }),
      ],
    );
  }

  Widget _buildLinkRow(String label, String linkText, VoidCallback? onTap) {
    final isEmpty = linkText == '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                linkText,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty ? Colors.grey.shade600 : Colors.blue,
                  decoration: isEmpty ? null : TextDecoration.underline,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(CurrencyDetail currencyDetail) {
    final description = currencyDetail.description ?? '';
    if (description.isEmpty) return const SizedBox.shrink();
    
    final isHtml = _isHtmlContent(description);
    final shortDescription = _getShortDescription(description, isHtml);
    final hasMore = description != shortDescription;
    final displayText = _isDescriptionExpanded ? description : shortDescription;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
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
              onTap: () => _copyDescription(description, isHtml),
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
        const SizedBox(height: 16),
        // 内容文本（支持 HTML）
        isHtml
            ? Html(
                data: displayText + (hasMore && !_isDescriptionExpanded ? '...' : ''),
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
                displayText + (hasMore && !_isDescriptionExpanded ? '...' : ''),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
        // 展开按钮
        if (hasMore) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
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

  String _getShortDescription(String description, bool isHtml) {
    if (isHtml) {
      final doc = html_parser.parse(description);
      final text = doc.body?.text ?? description;
      final paragraphs = text.split('\n').where((p) => p.trim().isNotEmpty).toList();
      
      if (paragraphs.length > 1) {
        return paragraphs[0];
      }
      
      const maxLength = 200;
      if (text.length > maxLength) {
        return _truncateHtml(description, maxLength);
      }
      return description;
    } else {
      final lines = description.split('\n');
      if (lines.length > 1) {
        return lines[0];
      }
      
      const maxLength = 200;
      if (description.length > maxLength) {
        return description.substring(0, maxLength);
      }
      return description;
    }
  }

  void _copyDescription(String description, bool isHtml) {
    final plainText = isHtml
        ? (html_parser.parse(description).body?.text ?? description)
        : description;
    Clipboard.setData(ClipboardData(text: plainText));
    MessageService.snackBar('已复制到剪贴板', duration: const Duration(seconds: 1));
  }

  /// 检查内容是否为 HTML
  bool _isHtmlContent(String text) {
    if (text.trim().isEmpty) return false;
    // 简单的 HTML 标签检测
    final htmlPattern = RegExp(r'<[a-z][\s\S]*>', caseSensitive: false);
    return htmlPattern.hasMatch(text);
  }

  /// 截断 HTML 内容
  String _truncateHtml(String html, int maxLength) {
    final doc = html_parser.parse(html);
    final text = doc.body?.text ?? '';
    
    if (text.length <= maxLength) {
      return html;
    }
    
    // 尝试找到第一个段落结束位置
    final firstParagraphEnd = html.indexOf('</p>');
    if (firstParagraphEnd > 0 && firstParagraphEnd < html.length) {
      return html.substring(0, firstParagraphEnd + 4);
    }
    
    return html.substring(0, maxLength);
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
