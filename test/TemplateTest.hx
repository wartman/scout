import haxe.unit.TestCase;

import scout.Template.html;

class TemplateTest extends TestCase {

  public function testEscape() {
    var unsafe = '<script>alert("oh noes");</script>';
    var expected = html('<div>This is ok:${unsafe}</div>');
    assertEquals('<div>This is ok:&lt;script&gt;alert("oh noes");&lt;/script&gt;</div>'
, expected);
  }

  public function testDoesNotEscapeNestedTemplates() {
    var header = function (title) return html('<h1>${title}</h1>');
    var actual = html('<div>${header("foo")}<p>bar</p></div>');
    assertEquals('<div><h1>foo</h1><p>bar</p></div>', actual);
  }

  public function testArrays() {
    var a = 'a';
    var b = 'b';
    var actual = html('<p>${[ a, b, 'c' ]}</p>');
    assertEquals('<p>abc</p>', actual);
  }

  public function testArraysFromVarOfStringArray() {
    var a = 'a';
    var b = 'b';
    var data = [ a, b, '<p>c</p>' ];
    var actual = html('<p>${data}</p>');
    assertEquals('<p>ab&lt;p&gt;c&lt;/p&gt;</p>', actual);
  }

  public function testArraysFromVarOfRenderResult() {
    var a = 'a';
    var b = 'b';
    var data:Array<scout.Template.RenderResult> = [ a, b, '<p>c</p>' ];
    var actual = html('<p>${data}</p>');
    assertEquals('<p>ab<p>c</p></p>', actual);
  }

  // public function testIteratedArray() {
  //   var data = [ 'a', 'b', 'c' ];
  //   var actual = html('${[ for (v in data) v + '_' ]}');
  //   assertEquals('a_b_c_', actual);
  // }

}