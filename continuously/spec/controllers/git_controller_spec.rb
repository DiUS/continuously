describe GitController do
  describe "POST /git/create" do
    before do
      allow(File).to receive('directory?')
      @mock_git = double(Git)
      allow(Git).to receive('open').and_return @mock_git
      allow(@mock_git).to receive('pull')
      @request = {
        repository: {
          name: "test",
          url: "http://whatever.com",
          id: "239"
        }
      }
    end

    it 'should checkout cleanly for a new repo' do
      expect(File).to receive('directory?').and_return false
      expect(Git).to receive('clone')
      post :create, payload: @request
    end

    it 'should update a checkout for a previously seen repo' do
      expect(File).to receive('directory?').and_return true
      expect(Git).to receive('open')
      expect(@mock_git).to receive('pull')
      post :create, payload: @request
    end
  end
end
