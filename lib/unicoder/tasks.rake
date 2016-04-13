namespace :unicoder do
  desc "(fetch)"
  task :fetch, [:identifier] do |t, args|
    Unicoder::Downloader.fetch(args.identifier)
  end

  desc "(index)"
  task :index, [:identifier] do |t, args|
    Unicoder::Builder.build(args.identifier)
  end
end
