class GithubHelper::Commands::Review::FileMatcher
  def initialize(name, interesting_when_exist=true)
    @interesting_name = name
    @interesting_when_exist = interesting_when_exist
    @matches = []
  end

  def process_file(pull_file)
    path = pull_file[:filename]
    path_split = path.split('/')
    filename = path_split[-1]

    if @interesting_name == filename
      @matches.push(filename)
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
      puts @interesting_name + ' file was not touched'
    else
      puts 'File ' + @interesting_name + ' was modified'
    end
  end
end