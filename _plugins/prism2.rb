module Jekyll

	class Prism < Liquid::Block
		include Liquid::StandardFilters

		LANGUAGE = /^[a-z\-]+$/
		OPTION_PARAMS = /(user|prompt|host|highlight|numbering|file|prompt|output)(?:\s*=\s*("[a-zA-Z0-9.,\-\/\s]*"|\-?[0-9]+))?/
		
		@language = nil
		@file = nil
		@numbering = false
		@highlight = false
        @output = false
        @host = nil
        @user = nil
        @prompt = nil

		def initialize(tag_name, markup, tokens)
			super
			
			markup = markup.strip
			
			tmp = markup.split(/\s+/, 2)	
			if tmp.count >= 1 then
				param = tmp[0].strip.downcase
				if LANGUAGE =~ param then
					@language = param
					if tmp.count == 2 then
						markup = tmp[1]
					else
						return
					end
				elsif not param.start_with? "file" then
					syntax_error
				end
			end
			
			
			params = markup.strip.scan(OPTION_PARAMS).to_a
			
			params.each { |x|
				if x.count == 1 || x[1] == nil then
					name = x[0]
					
					if name.eql? "numbering" then
						@numbering = true
					else
						syntax_error
					end
				elsif x.count == 2 then
					name = x[0]
					value = x[1]
					if name.eql? "file" then
						@file = value.tr('"', '')
					elsif name.eql? "highlight" then
						@highlight = value.tr('"', '')
					elsif name.eql? "numbering" then
						@numbering = value.to_i
			        elsif name.eql? "host" then
						@host = value.tr('"', '')
			        elsif name.eql? "user" then
						@user = value.tr('"', '')
		            elsif name.eql? "prompt" then
						@prompt = value.tr('"', '')
					elsif name.eql? "output" then
						@output = value.tr('"', '')
					end
				else
					syntax_error
				end
			}
		end


		def syntax_error
			raise SyntaxError.new(
				"Syntax Error in 'prism' - Valid syntax: prism <lang> [<option>(=<value>)] or prism file=path/to/file [<option>(=<value>)]"
			)
		end
		
		def render(context)
			code = super.to_s.strip
			dataline = ""
			
			linenumber = ""
			datastart = ""
			
			language = ""
			
			class_attr = ""
			
			unless @language.nil? then
				class_attr = class_attr + " language-" + @language + " "
			end
			
			if not @numbering.nil? then
				class_attr = class_attr + " line-numbers "
			end
			
			if @numbering.is_a? Numeric then
				datastart = "data-start='#{@numbering}'"
			end
			
			unless @highlight.nil? then
				dataline = "data-line='#{@highlight}'"
			end
			
		    unless @output.nil? then
				dataline = dataline +  " data-output='#{@output}' "
			end

		    unless @prompt.nil? then
                dataline = dataline + " data-prompt='#{@prompt}'"
                class_attr = class_attr + " command-line "			
            end

            unless @user.nil? || @host.nil?then
                dataline = dataline + " data-user='#{@user}'"
                dataline = dataline + " data-host='#{@host}'"
                class_attr = class_attr + " command-line "
            end

			if @file.nil?
				"<pre class=\"#{class_attr}\" #{datastart} #{dataline}><code>#{code}</code></pre>"
			else
				"<pre class='#{class_attr}' #{datastart} #{dataline} data-src='#{@file}'></pre>"
			end
			
		end
	end

end

Liquid::Template.register_tag('prism', Jekyll::Prism)