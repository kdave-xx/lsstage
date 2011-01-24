require 'aws/s3'
require 'mechanize'

class AmazonS3Asset
  
  include AWS::S3
  S3ID = "AKIAILAGSBFS7KC743AA"
  S3KEY = "hPLE5+63tDp5zLfox8SpKTdBipe10nZOMz92yHXH"

  def initialize
#    puts "connecting..."
    AWS::S3::Base.establish_connection!(
      :access_key_id     => S3ID,
      :secret_access_key => S3KEY
    )
  end
  
  def list_buckets
    AWS::S3::Service.buckets.collect {|b| b.name}
  end
  
  def find_bucket(bucket_name)
    Bucket.find(bucket_name)
  end

  def find_key(bucket, key)
    S3Object.find(key, bucket)
  end
  
  def delete_folder(bucket, key)
    Bucket.objects(bucket, :prefix => key).each do |o|
      unless folder_exists?(bucket, o.key)
        delete_key(bucket, o.key)
      end
    end
  end

  def delete_key(bucket, key)
    if exists?(bucket, key)
      S3Object.delete key, bucket
    end
  end

  def empty_bucket(bucket)
    bucket_keys(bucket).each do |k|

#      puts "deleting #{k}"
      delete_key(bucket,k)
    end
  end
  
  def bucket_keys(bucket)
    b = Bucket.find(bucket)
    b.objects.collect {|o| o.key}
  end

  def copy_over_bucket(from_bucket, to_bucket)
    empty_bucket(to_bucket)
    bucket_keys(from_bucket).each do |k|
      copy_between_buckets(from_bucket, to_bucket, k)
    end
  end
  
  def copy_folder_within_buckets(from_bucket, from_folder, to_folder = nil)
    Bucket.objects(from_bucket, :prefix => from_folder).each do |o|
      to_key = to_folder + "/" + o.key.gsub("public_themes/", "")
      S3Object.copy(o.key, to_key, from_bucket, :copy_acl => true)
    end
  end

  def copy_folder_over_buckets(from_bucket, to_bucket, from_folder, to_folder = nil)
    if folder_exists?(from_bucket, from_folder)
      Bucket.objects(from_bucket, :prefix => from_folder).each do |o|
        original_key = open(S3Object.url_for(o.key, from_bucket))
        to_key = to_folder + "/" + o.key.gsub("public_themes/", "")
        S3Object.store(to_key, original_key, to_bucket, :access => :public_read)
      end
    end
  end

  def copy_between_buckets(from_bucket, to_bucket, from_key, to_key = nil)
    if exists?(from_bucket, from_key)
      to_key = from_key if to_key.nil?
      url = "http://s3.amazonaws.com/#{from_bucket}/#{from_key}"
      filename = download(url)
      store_file(to_bucket,to_key,filename)
      File.delete(filename)
      return "http://s3.amazonaws.com/#{to_bucket}/#{to_key}"
    else
      return nil
    end
  end
  
  def objects(bucket, key)
    Bucket.objects(bucket, :prefix => key)
  end

  def store_file(bucket, key, filename, file_read=true)
    str = file_read ? File.open(filename).read : filename
    S3Object.store(
      key,
      str,
      bucket,
      :access => :public_read
      )
  end

  def download(url, save_as = nil)
    if save_as.nil?
      Dir.mkdir("amazon_s3_temp") if !File.exists?("amazon_s3_temp")
      save_as = File.join("amazon_s3_temp",File.basename(url))
    end
    begin
      agent = WWW::Mechanize.new {|a| a.log = Logger.new(STDERR) }
      img = agent.get(url)
      img.save_as(save_as)
      return save_as
    rescue
      raise "Failed on " + url + "  " + save_as
    end
  end

  def exists?(bucket,key)
    begin
      res = S3Object.find key, bucket
    rescue 
      res = nil
    end
    return !res.nil?
  end
  
  def folder_exists?(bucket,file_name,remove_extension=false)
    file_search_name = file_name.dup
    file_search_name << S3_FOLDER_EXT unless remove_extension
    Bucket.objects(bucket, :prefix => file_search_name).any?
  end
  
    def create_S3_folder(file_name, bucket_name, options={})
    S3Object.store(file_name + S3_FOLDER_EXT, '', bucket_name,
      {:access => :public_read,
       :content_type => "binary/octet-stream"}.update(options))
  end

      
end
