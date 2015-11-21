module Checkers
  def self.load!
    modules = %w( board game piece player )
    modules.each { |m| load File.expand_path "../#{m}.rb", __FILE__ }
  end

  load!
end
