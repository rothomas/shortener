require 'rspec'

describe RedirectRecord, type: :model do

  context 'creation' do

    before :all do
      @short_link = ShortLink.create(long_url: 'URL', user_id: 'fred', short_code: ShortCode.generate)
    end

    after :all do
      ShortLink.delete_all
    end

    after :each do
      RedirectRecord.delete_all
    end

    it 'must require a valid short_link' do
      expect { RedirectRecord.create!(referrer: "NOBODY", user_agent: "UNKNOWN") }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'creates records that belong to a short_link' do
      expect { @short_link.redirect_records.create!(referrer: 'NOBODY', user_agent: "UNKNOWN") }.not_to raise_error
    end

    it 'accepts a missing referrer' do
      expect { @short_link.redirect_records.create!(user_agent: 'UNKNOWN') }.not_to raise_error
    end

    it 'accepts a missing user_agent' do
      expect { @short_link.redirect_records.create!(referrer: 'NOBODY') }.not_to raise_error
    end

    it 'persists records' do
      redirect_record = @short_link.redirect_records.create!(referrer: "NOBODY", user_agent: "UNKNOWN")
      retrieved = RedirectRecord.find(redirect_record.id)
      expect(redirect_record).not_to equal(retrieved)
      expect(redirect_record.referrer).to eq(retrieved.referrer)
      expect(redirect_record.user_agent).to eq(retrieved.user_agent)
    end

    it 'segregates records by short_link' do
      alt_link = ShortLink.create!(long_url: 'URL2', user_id: 'barney', short_code: ShortCode.generate)
      record1 = @short_link.redirect_records.create!(referrer: "NOBODY", user_agent: "UNKNOWN")
      record2 = @short_link.redirect_records.create!(referrer: "NOBODY", user_agent: "UNKNOWN")
      record3 = alt_link.redirect_records.create!(referrer: "NOBODY", user_agent: "UNKNOWN")
      record4 = alt_link.redirect_records.create!(referrer: "NOBODY", user_agent: "UNKNOWN")
      records1 = ShortLink.find(@short_link.id).redirect_records
      records2 = ShortLink.find(alt_link.id).redirect_records
      expect(records1.size).to eq(2)
      expect(records2.size).to eq(2)
      expect(records1.map(&:id)).to match_array([record1.id, record2.id])
      expect(records2.map(&:id)).to match_array([record3.id, record4.id])
    end

  end

end
