module Pdftk

  # Represents a PDF
  class PDF
    attr_accessor :path

    def initialize path, all_fields=nil
      @path = path
      @_all_fields=all_fields
    end

    def fields_with_values
      fields.reject {|field| field.value.nil? or field.value.empty? }
    end

    def clear_values
      fields_with_values.each {|field| field.value = nil }
    end

    def export(output_pdf_path=nil, options = {})
      output_pdf_path ||= '-'
      output=nil
      Tempfile.open('pdftk-xfdf') do |f|
          f << xfdf
          f.flush
          output=Pdftk.run(%!"#{path}" fill_form "#{f.path}" output "#{output_pdf_path}" #{options_string(options)}!)
      end
      output
    end

    def xfdf
      @fields = fields_with_values

      if @fields.any?
        haml_view_path = File.join File.dirname(__FILE__), 'xfdf.haml'
        Haml::Engine.new(File.read(haml_view_path), :format => :xhtml).render(self)
      end
    end
    
    def field(name)
      fields.find { |field| field.name == name }
    end

    def fields
      unless @_all_fields
        field_output = Pdftk.run(%!"#{path}" dump_data_fields!)
        raw_fields   = field_output.split(/^---\n/).reject {|text| text.empty? }
        @_all_fields = raw_fields.map do |field_text|
          attributes = {}
          field_text.scan(/^(\w+): (.*)$/) do |key, value|
            attributes[key] = value
          end
          Field.new(attributes)
        end
      end
      @_all_fields
    end
    
    private
    
    def options_string(options)
      opts=[]
      opts<<'flatten' if options[:flatten]
      opts<<'drop_xfa' if options[:drop_xfa]
      opts<<'verbose' if options[:verbose]
      opts.join(' ')
    end  
  end

end
