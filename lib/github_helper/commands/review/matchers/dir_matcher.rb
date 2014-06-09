class GithubHelper::Commands::Review::DirMatcher
  def initialize(name, interesting_when_exist=true)
    @interesting_name = name
    @interesting_when_exist = interesting_when_exist
    @matches = []
  end

  def process_file(pull_file)
    path = pull_file[:filename]
    path_split = path.split('/')

    path_split[0...-1].each do |dirname|
      if @interesting_name.include?(dirname)
        @matches.push(dirname)
      end
    end
  end

  def interesting?
    if @interesting_when_exist
      @matches.length != 0
    else
      @matches.length == 0
    end
  end

  def report
    if @matches.empty?
      puts @interesting_name + ' dir was not touched'
    else
      puts 'Dir ' + @interesting_name + ' was changed'
    end
  end
end