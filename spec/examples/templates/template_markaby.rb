require 'spec/helper'

testcase_requires 'markaby'
require 'examples/templates/template_markaby'

describe 'Template Markaby' do
  ramaze

  it '/' do
    get('/').body.strip.should ==
      "<a href=\"/\">index</a> | <a href=\"/internal\">internal</a> | <a href=\"/external\">external</a>"
  end

  %w[/internal /external].each do |url|
    it url do
      html = get(url).body
      html.should_not == nil
      html.should =~ %r{<title>Template::Markaby (internal|external)</title>}
      html.should =~ %r{<h1>The (internal|external) Template for Markaby</h1>}
    end
  end
end