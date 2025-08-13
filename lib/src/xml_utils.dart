import 'package:xml/xml.dart' as xml;

/// Utility functions for robust XML parsing
class XmlUtils {
  /// Safely parse XML string with better error handling and diagnostics
  static xml.XmlDocument safeParseXml(String xmlStr, {String? context}) {
    try {
      // Trim whitespace and check for empty/null response
      xmlStr = xmlStr.trim();
      if (xmlStr.isEmpty) {
        throw Exception('Empty XML response received${context != null ? ' in $context' : ''}');
      }
      
      // Check if response looks like HTML error page instead of XML
      if (xmlStr.toLowerCase().startsWith('<html') || 
          xmlStr.toLowerCase().startsWith('<!doctype html')) {
        throw Exception('Received HTML response instead of XML - likely an error page${context != null ? ' in $context' : ''}');
      }
      
      // Check for multiple XML declarations which would cause parsing issues
      final xmlDeclarationCount = '<?xml'.allMatches(xmlStr).length;
      if (xmlDeclarationCount > 1) {
        throw Exception('Multiple XML declarations found in response - malformed XML${context != null ? ' in $context' : ''}');
      }
      
      // If the XML doesn't start with <?xml or <, it might be malformed
      if (!xmlStr.startsWith('<?xml') && !xmlStr.startsWith('<')) {
        // Look for the first < character and trim everything before it
        final firstBracket = xmlStr.indexOf('<');
        if (firstBracket > 0) {
          print('Warning: Trimming ${firstBracket} characters before first XML tag${context != null ? ' in $context' : ''}');
          xmlStr = xmlStr.substring(firstBracket);
        } else {
          throw Exception('No valid XML tags found in response${context != null ? ' in $context' : ''}');
        }
      }
      
      // Log the XML for debugging (first 200 chars)
      print('Parsing XML${context != null ? ' for $context' : ''} (${xmlStr.length} chars): ${xmlStr.substring(0, xmlStr.length > 200 ? 200 : xmlStr.length)}...');
      
      // Parse the XML using the xml.XmlDocument.parse method
      return xml.XmlDocument.parse(xmlStr);
      
    } catch (e) {
      print('XML parsing error${context != null ? ' in $context' : ''}: $e');
      print('Raw XML response (${xmlStr.length} chars): $xmlStr');
      rethrow;
    }
  }
  
  /// Find a single element by name, with better error messaging
  static xml.XmlElement findSingleElement(xml.XmlDocument document, String elementName, {String? context}) {
    final elements = document.findAllElements(elementName);
    if (elements.isEmpty) {
      throw Exception('No <$elementName> element found in XML response${context != null ? ' in $context' : ''}');
    }
    if (elements.length > 1) {
      throw Exception('Multiple <$elementName> elements found in XML response, expected single element${context != null ? ' in $context' : ''}');
    }
    return elements.single;
  }
}
