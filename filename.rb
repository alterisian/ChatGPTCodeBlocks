class Filename
  # Attempts to extract a filename based on different strategies.
  def self.extract(content, preceding_text)
    puts "Attempting to extract filename..."
    filename = extract_from_code_comment(content)
    filename ||= extract_from_preceding_text(preceding_text)
    filename ||= extract_from_immediate_preceding_line(preceding_text)
    puts "Extracted filename: #{filename || 'Default filename will be used'}"
    filename
  end

  private

  def self.extract_from_code_comment(content)
    # Strategy 1: Extract filename from code comments inside the block
    if match = content.match(/\/\/ Filename: (\S+)|# Filename: (\S+)/)
      filename = match.captures.compact.first
      puts "Filename extracted from code comment: #{filename}"
      return filename
    end
    nil
  end

  def self.extract_from_preceding_text(text)
    # Strategy 2: Extract filename from text preceding the code block
    return nil if text.nil?
    if match = text.match(/filename:\s*(\S+)/i)
      filename = match[1]
      puts "Filename extracted from preceding text: #{filename}"
      return filename
    end
    nil
  end

  def self.extract_from_immediate_preceding_line(text)
    # Strategy 3: Extract filename from the immediate line before the code block
    return nil if text.nil?
    lines = text.split("\n")
    if lines.any?
      lines.reverse_each do |line|
        if match = line.match(/filename:\s*(\S+)/i)
          filename = match[1]
          puts "Filename extracted from immediate preceding line: #{filename}"
          return filename
        end
      end
    end
    nil
  end
end
