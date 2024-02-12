require 'nokogiri'
require 'json'

require_relative '../filename' # Adjust the path as necessary to require the Filename class

RSpec.describe Filename, '.extract' do
  context 'when extracting from code comment' do
    it 'extracts filename from a single-line comment in JavaScript' do
      content = "// Filename: example.js\nconst foo = 'bar';"
      expect(Filename.extract(content, '')).to eq('example.js')
    end

    it 'extracts filename from a single-line comment in Python' do
      content = "# Filename: example.py\ndef foo():\n    pass"
      expect(Filename.extract(content, '')).to eq('example.py')
    end

    it 'returns nil if no filename comment is present' do
      content = "const foo = 'bar';"
      expect(Filename.extract(content, '')).to be_nil
    end

    it 'ignores non-filename comments' do
      content = "// This is just a comment\nconst foo = 'bar';"
      expect(Filename.extract(content, '')).to be_nil
    end

    it 'extracts filename from code blocks in conversation JSON data' do
      puts "using raw.html"
      file_path = File.expand_path('../fixtures/raw.html', __FILE__) # Adjust the path as needed
      html_content = File.read(file_path)
      doc = Nokogiri::HTML(html_content)
  
      # Find the <script> tag containing the JSON data
      script_content = doc.css('script#__NEXT_DATA__').first.content
      data = JSON.parse(script_content)
  
      # Navigate through the JSON object to find the conversation content
      messages = data.dig("props", "pageProps", "serverResponse", "data", "mapping")&.values || []
      
      filenames_extracted = []
  
      messages.each do |msg|
        parts = msg.dig("message", "content", "parts")
        next unless parts # Skip messages without 'parts'
  
        code_blocks = parts.join.scan(/```(.*?)```/m).flatten
  
        code_blocks.each do |block|
          filename = Filename.extract(block, parts.join)
          filenames_extracted.push(filename) unless filename.nil?
        end
      end
  
      expect(filenames_extracted).not_to be_empty
      # Optionally, if you have specific expectations about filenames:
      # expect(filenames_extracted).to include('expected_filename.ext')
    end
  end
end
