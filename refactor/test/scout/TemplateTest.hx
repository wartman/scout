package scout;

import scout.Template.html;

using hex.unittest.assertion.Assert;

class TemplateTest {

  @Test
  public function testEscape() {
    var unsafe = '<script>alert("oh noes");</script>';
    var expected = html('<div>This is ok:${unsafe}</div>');
    expected.equals('<div>This is ok:&lt;script&gt;alert("oh noes");&lt;/script&gt;</div>');
  }

  @Test
  public function testDoesNotEscapeNestedTemplates() {
    var header = function (title) return html('<h1>${title}</h1>');
    var actual = html('<div>${header("foo")}<p>bar</p></div>');
    actual.equals('<div><h1>foo</h1><p>bar</p></div>');
  }

  @Test
  public function testArrays() {
    var a = 'a';
    var b = 'b';
    var actual = html('<p>${[ a, b, 'c' ]}</p>');
    actual.equals('<p>abc</p>');
  }

  @Test
  public function testArraysFromVarOfStringArray() {
    var a = 'a';
    var b = 'b';
    var data = [ a, b, '<p>c</p>' ];
    var actual = html('<p>${data}</p>');
    actual.equals('<p>ab&lt;p&gt;c&lt;/p&gt;</p>');
  }

  @Test
  public function testArraysFromVarOfRenderResult() {
    var a = 'a';
    var b = 'b';
    var data:Array<scout.RenderResult> = [ a, b, '<p>c</p>' ];
    var actual = html('<p>${data}</p>');
    actual.equals('<p>ab<p>c</p></p>');
  }

}
