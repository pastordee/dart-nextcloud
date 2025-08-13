import 'package:test/test.dart';
import 'package:nextcloud/src/xml_utils.dart';

void main() {
  group('XmlUtils', () {
    test('should handle valid XML correctly', () {
      const validXml = '''<?xml version="1.0" encoding="UTF-8"?>
<root>
  <data>test data</data>
</root>''';

      final document = XmlUtils.safeParseXml(validXml, context: 'test');
      final dataElement = XmlUtils.findSingleElement(document, 'data', context: 'test');
      
      expect(dataElement.text, equals('test data'));
    });

    test('should throw meaningful error for empty XML', () {
      expect(
        () => XmlUtils.safeParseXml('', context: 'test'),
        throwsA(
          predicate((e) => e.toString().contains('Empty XML response received in test'))
        ),
      );
    });

    test('should throw meaningful error for HTML response', () {
      const htmlResponse = '<!DOCTYPE html><html><head><title>Error</title></head><body>Error page</body></html>';
      
      expect(
        () => XmlUtils.safeParseXml(htmlResponse, context: 'test'),
        throwsA(
          predicate((e) => e.toString().contains('Received HTML response instead of XML'))
        ),
      );
    });

    test('should handle malformed XML with prefix text', () {
      const malformedXml = 'Some prefix text <?xml version="1.0"?><root><data>test</data></root>';
      
      final document = XmlUtils.safeParseXml(malformedXml, context: 'test');
      final dataElement = XmlUtils.findSingleElement(document, 'data', context: 'test');
      
      expect(dataElement.text, equals('test'));
    });

    test('should throw error for missing element', () {
      const xmlWithoutData = '<?xml version="1.0"?><root><other>test</other></root>';
      
      final document = XmlUtils.safeParseXml(xmlWithoutData, context: 'test');
      
      expect(
        () => XmlUtils.findSingleElement(document, 'data', context: 'test'),
        throwsA(
          predicate((e) => e.toString().contains('No <data> element found in XML response in test'))
        ),
      );
    });

    test('should throw error for multiple elements when single expected', () {
      const xmlWithMultipleData = '''<?xml version="1.0"?>
<root>
  <data>first</data>
  <data>second</data>
</root>''';
      
      final document = XmlUtils.safeParseXml(xmlWithMultipleData, context: 'test');
      
      expect(
        () => XmlUtils.findSingleElement(document, 'data', context: 'test'),
        throwsA(
          predicate((e) => e.toString().contains('Multiple <data> elements found'))
        ),
      );
    });
  });
}
