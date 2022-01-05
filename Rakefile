desc "Create a post in _posts"
task :new do
    puts "Input File Path(book/life/resource/tech/tool,default _posts Root)："
    @dir = STDIN.gets.chomp
    puts "Input File Name(for Url)："
    @url = STDIN.gets.chomp
    puts "Input Article Title(for Article)："
    @name = STDIN.gets.chomp
    puts "Input Article Subitle(for Article)："
    @subtitle = STDIN.gets.chomp
    puts "Input Article Categories(工具｜资源｜生活｜技术｜读书 Separated By Spaces)："
    @categories = STDIN.gets.chomp
    puts "Input Article Tags(Separated By ,)"
    @tags = STDIN.gets.chomp
    puts "Input Article Keywords(Separated By ,)"
    @keywords = STDIN.gets.chomp
    puts "Input Cover url(Article cover url)："
    @cover = STDIN.gets.chomp

    @slug = "#{@url}"
    @slug = @slug.downcase.strip.gsub(' ', '-')
    @date = Time.now.strftime("%F")
    @post_url = (@dir=="") ? "" : ("/" + "#{@dir}");
    @post_name = "_posts#{@post_url}/#{@date}-#{@slug}.md"
    if File.exist?(@post_name)
       abort("Failed to create the file name already exists !")
    end
    FileUtils.touch(@post_name)
    open(@post_name, 'a') do |file|
        file.puts "---"
        file.puts "layout: post"
        file.puts "title: #{@name}"
        file.puts "subtitle: #{@subtitle}"
        file.puts "date: #{Time.now}"
        file.puts "categories: #{@categories}"
        file.puts "tags: #{@tags}"
        file.puts "keywords: #{@keywords}"
        file.puts "cover: #{@cover}"
        file.puts "---"
    end
    exec "vi #{@post_name}"
end
