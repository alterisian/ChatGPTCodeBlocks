# usage: ruby chat_code.rb <chatGPT_url>
# output: code underneath the output directory, inside a numbered subdirectory
# disclaimer: this is provided as is. Run at your own risk. It saves code as text only currently
# ----------------

require 'net/http'
require 'uri'
require 'nokogiri'
require 'openssl'
require 'fileutils'
require 'json'

require_relative 'filename' # Ensure this is correct based on your file structure

class ChatCode
  def self.fetch_and_save_code(url)
    content = fetch_content(url)
    puts "Content retrieved: #{content.length} characters"
    unless content.empty?
      output_dir = create_output_subdirectory
      save_raw_content(content, output_dir)
      save_code_blocks(content, output_dir)
    end
  end

  private

  def self.fetch_content(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      puts "Content retrieved successfully!"
      response.body
    else
      puts "Failed to retrieve content. Error code: #{response.code}"
      ''
    end
  end

  def self.save_raw_content(html_content, output_dir)
    filepath = File.join(output_dir, "raw.html")
    File.open(filepath, 'w') do |file|
      file.write(html_content)
    end
    puts "Saved raw HTML content to #{filepath}"
  end

  def self.save_code_blocks(html_content, output_dir)
    doc = Nokogiri::HTML(html_content)

    # Find the <script> tag containing the JSON data
    script_content = doc.css('script#__NEXT_DATA__').first.content
    data = JSON.parse(script_content)

    # Navigate through the JSON object to find the conversation content
    messages = data.dig("props", "pageProps", "serverResponse", "data", "mapping")&.values || []
    
    messages.each_with_index do |msg, msg_index|
      parts = msg.dig("message", "content", "parts")
      next unless parts # Skip messages without 'parts'

      code_blocks = parts.join.scan(/```(.*?)```/m).flatten

      code_blocks.each_with_index do |block, block_index|
        # Use a method from Filename to determine the filename
        # Make sure to provide a default filename in case extract returns nil
        filename = Filename.extract(block, parts.join) || "default_code_block_#{msg_index + 1}_#{block_index + 1}.txt"
        filepath = File.join(output_dir, filename)
        File.open(filepath, 'w') do |file|
          file.write(block.strip)
        end
        puts "Saved code block to #{filepath}"
      end
    end
  end

  def self.create_output_subdirectory
    base_dir = './output'
    FileUtils.mkdir_p(base_dir) unless Dir.exist?(base_dir)
    
    # Find the next incremental subdirectory number
    next_dir_number = Dir.children(base_dir).map(&:to_i).sort.last.to_i + 1
    next_dir = File.join(base_dir, next_dir_number.to_s)
    FileUtils.mkdir_p(next_dir)
    
    next_dir
  end
end

if ARGV.length != 1
  puts "Usage: ruby chat_code.rb <url>"
else
  url = ARGV[0]
  ChatCode.fetch_and_save_code(url)
end
