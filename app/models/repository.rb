class Repository < Resource
  include ActiveModel::Model

  attr_accessor :name, :tags

  def self.list(count: 100, last: nil)
    response = client.get "/v2/_catalog", { n: count, last: last }.compact
    entries  = response.body["repositories"].map { |name| new(name: name) }

    Collection.new entries: entries, more: response.headers.has_key?("Link")
  end

  def self.find(name, count: 500, last: nil)
    begin
      response = client.get "/v2/#{name}/tags/list", { n: count, last: last }.compact
      tags     = response.body["tags"]
    rescue Faraday::ResourceNotFound => e
      tags = nil
    end

    new(
      name: name,
      tags: Array.wrap(tags)
    )
  end

  def namespace(root = "")
    name.split("/").size == 1 ? root : name.split("/")[0...-1].join('/')
  end

  def image
    name.split("/").last
  end
end

