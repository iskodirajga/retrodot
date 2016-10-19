RSpec.describe ChatOps::TimeStampHelpers do
  let(:helper) { Class.new { extend ChatOps::TimeStampHelpers } }

  describe ".parse_timestamp" do
    before(:each) do
      allow(Config).to receive(:time_zone).and_return('US/Pacific')
    end

    let(:date_in_dst) do
      ActiveSupport::TimeZone[Config.time_zone].parse('2016-09-07 05:00:00 PDT')
    end

    let(:date_not_in_dst) do
      ActiveSupport::TimeZone[Config.time_zone].parse('2015-12-07 05:00:00 PDT')
    end

    let(:test_date) { date_in_dst }
    let(:threepm_pdt) { test_date.time_zone.local(test_date.year, test_date.month, test_date.day, 15, 0, 0) }
    let(:threepm_edt) { ActiveSupport::TimeZone["US/Eastern"].local(test_date.year, test_date.month, test_date.day, 15, 0, 0) }
    let(:threepm_est) { ActiveSupport::TimeZone["US/Eastern"].local(date_not_in_dst.year, date_not_in_dst.month, date_not_in_dst.day, 15, 0, 0) }

    it "handles relative times" do
      Timecop.freeze(test_date) do
        expect(helper.parse_timestamp("5 minutes ago")).to eq(test_date - 5.minutes)
      end
    end


    it "handles times starting with 'at'" do
      Timecop.freeze(test_date) do
        expect(helper.parse_timestamp("at 3pm")).to eq threepm_pdt
      end
    end

    it "handles times with time zones" do
      Timecop.freeze(test_date) do
        expect(helper.parse_timestamp("3pm EDT")).to eq threepm_edt
        expect(helper.parse_timestamp("3pm -0400")).to eq threepm_edt
      end
    end

    it "corrects 'EST' to 'EDT' during daylight time" do
      Timecop.freeze(date_in_dst) do
        expect(helper.parse_timestamp("3pm EST")).to eq threepm_edt
      end
    end

    it "corrects 'EDT' to 'EST' during standard time" do
      Timecop.freeze(date_not_in_dst) do
        expect(helper.parse_timestamp("3pm EDT")).to eq threepm_est
      end
    end
  end
end
