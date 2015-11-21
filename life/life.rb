module Life
  def self.load!
    modules = %w( board game piece )
    modules.each { |m| load File.expand_path "../#{m}.rb", __FILE__ }
  end

  load!
end
