require 'rspec'

describe ShortLinkController, type: :controller do

  context 'shorten a URL' do

    after :each do
      ShortLink.delete_all
    end

    it 'should accept long_url and user_id' do
      expect {post :shorten, params: {long_url: 'URL', user_id: 'fred'}}.not_to raise_error
    end

    it 'should require long_url' do
      expect {post(:shorten, params: {user_id: 'fred'})}.to raise_error ActionController::ParameterMissing
    end

    it 'should require user_id' do
      expect {post(:shorten, params: {long_url: 'URL'})}.to raise_error ActionController::ParameterMissing
    end

    it 'should ignore invalid parameters' do
      expect {post :shorten, params: {long_url: 'URL', user_id: 'fred', short_code: 'ABCDE'}}.not_to raise_error
      result = JSON.parse(response.body)
      expect(result['short_link']).not_to end_with('ABCDE')
    end

    it 'should return different IDs for different URLs' do
      post :shorten, params: {long_url: 'URL', user_id: 'fred'}
      result1 = JSON.parse(response.body)
      short_link1 = result1['short_link']

      post :shorten, params: {long_url: "URL2", user_id: 'fred'}
      result2 = JSON.parse(response.body)
      short_link2 = result2['short_link']
      expect(short_link1).not_to eq(short_link2)
    end

    it 'should return different IDs for different User IDs' do
      post :shorten, params: {long_url: 'URL', user_id: 'fred'}
      result1 = JSON.parse(response.body)
      short_link1 = result1['short_link']

      post :shorten, params: {long_url: 'URL', user_id: 'barney'}
      result2 = JSON.parse(response.body)
      short_link2 = result2['short_link']
      expect(short_link1).not_to eq(short_link2)
    end

    it 'should return the same ID for the same URL and User ID' do
      post :shorten, params: {long_url: 'URL', user_id: 'fred'}
      result1 = JSON.parse(response.body)
      short_link1 = result1['short_link']

      post :shorten, params: {long_url: 'URL', user_id: 'fred'}
      result2 = JSON.parse(response.body)
      short_link2 = result2['short_link']
      expect(short_link1).to eq(short_link2)
    end

  end

  context 'follow a short link' do

    it 'should redirect to a valid id' do
      post :shorten, params: {long_url: 'URL', user_id: 'fred'}
      short_code = JSON.parse(response.body)['short_link'].split('/')[-1]
      get :follow, params: {short_code: short_code}
      expect(response).to redirect_to('URL')
    end

    it 'should return 404 if no such short link' do
      get :follow, params: {short_code: 'ABCDE'}
      expect(response.status).to eq(404)
      expect(response.body).to eq('404 Not Found')
    end

  end

  context 'analytics' do

    after :each do
      RedirectRecord.delete_all
    end

    it 'should record a redirect' do
      link = ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate)
      request.headers.merge!('Referrer': 'REFERRER', 'User-Agent': 'AGENT')
      get :follow, params: {short_code: link.short_code}
      expect(link.redirect_records.size).to eq(1)
      expect(link.redirect_records.first.referrer).to eq('REFERRER')
      expect(link.redirect_records.first.user_agent).to eq('AGENT')
    end

    it 'should ignore a failed redirect' do
      get :follow, params: {short_code: 'ABCDE'}
      expect(RedirectRecord.all).to be_empty
    end

    it 'should use analytics flow when short_code ends with +' do
      link = ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate)
      get :follow, params: {short_code: "#{link.short_code}+"}
      expect(response.status).to eq(200)
      analytics = JSON.parse(response.body)
      expect(analytics['response']).not_to be_nil
      expect(analytics['response'].length).to eq(0)
    end

    it 'should return 404 when analytics requested for nonexistent short code' do
      get :follow, params: {short_code: 'ABCDE+'}
      expect(response.status).to eq(404)
      expect(response.body).to eq('404 Not Found')
    end

    it 'should return stored analytics' do
      link = ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate)
      request.headers.merge!('Referrer': 'REFERRER1', 'User-Agent': 'AGENT1')
      get :follow, params: {short_code: link.short_code}
      request.headers.merge!('Referrer': 'REFERRER2', 'User-Agent': 'AGENT2')
      get :follow, params: {short_code: link.short_code}
      request.headers.merge!('Referrer': 'REFERRER3', 'User-Agent': 'AGENT3')
      get :follow, params: {short_code: link.short_code}

      get :follow, params: {short_code: "#{link.short_code}+"}
      expect(response.status).to eq(200)
      analytics = JSON.parse(response.body)
      expect(analytics['response']).not_to be_nil
      expect(analytics['response'].length).to eq(3)
      analytics['response'].each do |item|
        expect(item.keys).to match_array(%w{time referrer user_agent})
      end
      expect(analytics['response'].map {|r| r['referrer']}).to match_array(%w{REFERRER1 REFERRER2 REFERRER3})
      expect(analytics['response'].map {|r| r['user_agent']}).to match_array(%w{AGENT1 AGENT2 AGENT3})
      analytics['response'].map {|r| r['time']}.each do |timestamp|
        expect(timestamp).to match /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/
      end
    end

  end

end