# Copyright (c) 2016-2022 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'base64'
require 'nokogiri'
require_relative '../version'
require_relative 'mongo'
require_relative 'dynamo'

#
# Log.
#
class Log
  def initialize(client, repo, vcs = 'github')
    # @todo #312:30min Be sure to handle the use case where projects from
    #  different vcs have the same <user/repo_name>. This will cause a conflict.
    @vcs = (vcs || 'github').downcase
    @repo = @vcs == 'github' ? repo : Base64.encode64(repo + @vcs).gsub(%r{[\s=/]+}, '')
    raise 'You need to specify your cloud VCS' unless ['github', 'gitlab'].include?(@vcs)

    @db = MongoLog.new(client, @repo, @vcs) if client.name == 'MONGO'
    @db = DynamoLog.new(client, @repo, @vcs) unless client.name == 'MONGO'
  end

  def put(tag, text)
    @db.put(tag, text)
  end

  def get(tag)
    @db.get(tag)
  end

  def exists(tag)
    @db.exists(tag)
  end

  def delete(time, tag)
    @db.delete(time, tag)
  end

  def list(since = Time.now.to_i)
    @db.list(since)
  end
end
