require 'rspec'

describe ShortLink, type: :model do

  context 'creation by URL' do

    after :each do
      ShortLink.delete_all
    end

    it 'should persist records' do
      link = ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate)
      retrieved = ShortLink.find(link.id)
      expect(link).not_to equal(retrieved)
      expect(link.long_url).to eq(retrieved.long_url)
      expect(link.short_code).to eq(retrieved.short_code)
      expect(link.user_id).to eq(retrieved.user_id)
    end

    it 'should reject duplicate URLs for the same User ID' do
      ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate)
      expect { ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'should accept duplicate URLs for different User IDs' do
      ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate)
      expect { ShortLink.create!(long_url: 'URL', user_id: 'barney', short_code: ShortCode.generate) }.not_to raise_error
    end

    it 'should reject duplicate IDs' do
      id = ShortCode.generate
      ShortLink.create!(long_url: 'URL', user_id: 'fred', short_code: id)
      expect { ShortLink.create!(long_url: 'URL2', short_code: id) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'should reject missing URLs' do
      expect { ShortLink.create!(user_id: 'fred', id: ShortCode.generate) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'should reject missing User IDs' do
      expect { ShortLink.create!(long_url: 'URL', id: ShortCode.generate) }.to raise_error ActiveRecord::RecordInvalid

    end

    it 'should reject missing IDs' do
      expect { ShortLink.create!(long_url: 'URL', user_id: 'fred') }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'should respect find_or_create logic' do
      link1 = ShortLink.find_or_create_by!(long_url: 'URL', user_id: 'fred') { |link| link.short_code = ShortCode.generate }
      link2 = ShortLink.find_or_create_by!(long_url: 'URL', user_id: 'fred') { |link| link.short_code = ShortCode.generate }
      expect(link1.short_code).to eq(link2.short_code)
    end
  end

end
