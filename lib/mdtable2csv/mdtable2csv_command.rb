require 'thor'
require 'pathname'
require 'redcarpet'
require 'nokogiri'
require 'clipboard'

# Configure Load path
$:.unshift Pathname.new(__FILE__).dirname.join.expand_path.to_s

module MarkdownTableToCSV
  class CLI < Thor

    desc 'convert', 'convert markdown table to csv/tsv file'
    # Input file
    option :file, :type => :string, :required => true

    # Output file path
    option :o, :type => :string, :required => true

    # Output file format(csv/tsv)
    option :type, :type => :string, :default => 'csv'

    option :confluence, :type => :boolean, :default => false
    def convert
      input_file_path  = options[:file]
      output_file_path = options[:o]
      output_file_type = options[:type]
      is_confluence    = options[:confluence]
     
      # Load text
      text = File.open(input_file_path, 'r').read()

      # Initialize Markdown parser
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :tables => true)
      
      # Convert Markdown to HTML
      html_body = markdown.render(text)
      
      # Parse HTML to Nokogiri instance
      html = nil
      if is_confluence
        html = Nokogiri::HTML.fragment(html_body)
      else
        html = Nokogiri::HTML(html_body)
      end
      
      # Replace <table>
      html.search('table').each do |table|
        table['rules'] = 'all'
      end
      
      # Change header color
      html.search('thead').each do |header|
        header['style'] = 'background: #E0E0E0; font-weight: bold;'
      end
      
      # Convert html/csv/tsv
      output_text = nil
      case output_file_type
      when /csv|tsv/
        output_text = []

        # Choose tr tag
        html.xpath('//table/*/tr').each do |row|
          tarray = []

          # Choose th/td tag
          row.xpath('th|td').each do |cell|
            tarray << cell.text
          end
          
          # Formatting csv or tsv
          if output_file_type == 'csv'
            output_text << tarray.join(',')
          else
            output_text << tarray.join("\t")
          end
        end
        output_text = output_text.join("\n")
      when 'html'
       output_text = html.to_s
      end
      
      case output_file_path
      when 'stdout'
        puts output_text
      when 'clipboard'
        Clipboard.copy output_text

        puts 'copied'
        exit
      end

      # Write file
      File.open(output_file_path,'w') do |o|
        o.puts output_text
      end
    end
  end
end

