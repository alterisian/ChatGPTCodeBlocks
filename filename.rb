class Filename
  # Extracts a filename from the content.
  def self.extract(content, preceding_text)
    # Strategy 1 & 2: Look in the preceding text for a filename pattern
    filename = extract_from_preceding_text(preceding_text) || extract_from_comment_inside_code(content)
    filename ? format_filename(filename) : nil
  end

  private

  def self.extract_from_preceding_text(text)
    # Look for a filename pattern in the text immediately before the code block
    # This could be refined based on the actual patterns observed
    if text =~ /###\s*(.*?)(?=\s*\n```)/m
      return $1.strip
    elsif text =~ /(\S+)\.(\w+)\s*$/ # Matches 'filename.extension' at the end of the text
      return $1.strip
    end
    nil
  end

  def self.extract_from_comment_inside_code(content)
    # Strategy 3: Look for a filename in a comment at the start of the code block
    if content =~ /\/\/\s*File:\s*(\S+)/
      return $1.strip
    elsif content =~ /#\s*File:\s*(\S+)/ # For Ruby or Python style comments
      return $1.strip
    end
    nil
  end

  def self.format_filename(filename)
    # Ensure the filename is safe and ends with a .txt extension
    # This method can be expanded based on the filename patterns and requirements
    filename.gsub!(/[^0-9A-Za-z.\-]/, '_') # Replace any non-alphanumeric character with an underscore
    filename += ".txt" unless filename.end_with?(".txt")
    filename
  end
end
