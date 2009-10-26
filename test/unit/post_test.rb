require 'test_helper'

class PostTest < ActiveSupport::TestCase

  test "Post.make" do
    assert_difference 'Post.count' do
      Post.make
    end
  end
    
  test "is not valid without a user_id" do
    p = Post.new
    assert_equal false, p.valid?
    assert p.errors[:user_id]
  end
  
  test "to_s returns attachment_file_name" do
    r = Post.make
    assert_equal r.attachment_file_name, r.to_s
  end

  test "attachment_file_name is unique" do
    r1 = Post.make
    r2 = Post.create { |r| r.user = User.make; r.attachment_file_name = r1.attachment_file_name }
    assert r2.errors.on(:attachment_file_name)
  end

  test "should create an post via (stubbed out) url" do
    Post.any_instance.expects(:do_download_remote_file).returns(File.open("#{Rails.root}/test/fixtures/files/rails.png"))
    r = Post.create! { |r| r.user = User.make; r.attachment = nil; r.attachment_url = 'rails.png' }
    assert_equal 'rails.png', r.attachment_remote_url # check for correct original attachment_url value
    assert_equal 'image/png', r.attachment_content_type # check for correct type
    assert_equal 6646, r.attachment_file_size # check for correct file size
  end

  test "should require post provided via (stubbed out) url to be valid" do
    Post.any_instance.expects(:do_download_remote_file).returns(nil)
    assert_no_difference 'Post.count' do
      r = Post.create(:user => User.make, :attachment => nil, :attachment_url => 'invalid')
      assert r.errors.on(:attachment_file_name)
    end
  end
  
end
