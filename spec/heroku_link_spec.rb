require File.dirname(__FILE__) + '/base'

describe HerokuLink do
	before(:each) do
		@client = HerokuLink.new(nil, nil, nil)
	end

	it "list -> get a list of this user's apps" do
		@client.should_receive(:transmit).and_return <<EOXML
<?xml version="1.0" encoding="UTF-8"?>
<apps type="array">
	<app><name>myapp1</name></app>
	<app><name>myapp2</name></app>
</apps>
EOXML
		@client.list.should == %w(myapp1 myapp2)
	end

	it "create -> create a new blank app" do
		@client.should_receive(:transmit).and_return <<EOXML
<?xml version="1.0" encoding="UTF-8"?>
<app><name>untitled-123</name></app>
EOXML
		@client.create.should == "untitled-123"
	end

	it "create(name) -> create a new blank app with a specified name" do
		@client.should_receive(:post).with("/apps?app[name]=newapp").and_return <<EOXML
<?xml version="1.0" encoding="UTF-8"?>
<app><name>newapp</name></app>
EOXML
		@client.create("newapp").should == "newapp"
	end

	it "destroy(name) -> destroy the named app" do
		@client.should_receive(:delete).with("/apps/destroyme")
		@client.destroy("destroyme")
	end

	it "upload_authkey(key) -> send the ssh authkey to authorize git push/pull" do
		@client.should_receive(:transmit) do |req, payload|
			req.path.should == "/user/authkey"
			payload.should == 'my key'
		end
		@client.upload_authkey('my key')
	end
end
