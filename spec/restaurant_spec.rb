require 'spec_helper'

describe Restaurant do
  let(:restaurant) { create :live_restaurant }
  let(:feature_type) { create :feature_type, name: VersionControlledFeatures::SIGNATURE_SCREEN }
  it {should_not allow_mass_assignment_of(:metadata_id)}

  it_behaves_like 'the mossy api spec' do
    let(:record) { create :restaurant }
  end

  describe 'validations' do
    it_behaves_like 'required attributes', :name,
      :device_limit,
      :table_data_version,
      :restaurant_data_version,
      :menu_data_version,
      :menu_group_format,
      :cc_tips_pay_at_shift_end,
      :print_receipt_on_close,
      :comp_includes_tax,
      :use_courses,
      :table_track_guest_count,
      :table_position_numbers_allowed,
      :table_position_numbers_required,
      :table_position_numbers_gender_enabled,
      :has_delivery_service,
      :has_take_out,
      :checks_show_properties_dialog,
      :manager_approvals_with_cc,
      :uses_firing,
      :auto_close,
      :status,
      :show_suggested_tips,
      :skip_signature_for_small_orders,
      :print_void_tickets,
      :autograt_pay_at_shift_end
    it_behaves_like 'required length', 256, :name,
      :address1,
      :address2,
      :city,
      :country,
      :timezone,
      :stomp_name,
      :stomp_host,
      :admin_email,
      :preferred_ssid
    it_behaves_like 'required length', 128, :state,
      :key,
      :auto_close_task
    it_behaves_like 'required length', 32, :postcode
    it_behaves_like 'required length', 64, :contact_ph
    it_behaves_like 'required length', 75, :receipt_email_from_address
    it_behaves_like 'required length', 10, :delivery_number
    it_behaves_like 'inclusion of field in range', :status, (1..5)
    it_behaves_like 'inclusion of field in range', :migration_status, (1..4)
    it_behaves_like 'inclusion of field in range', :suggested_tip_default, (1..4)

    context 'invalid default gratuity percent' do
      let(:restaurant) { build(:restaurant, default_gratuity_percent: "7.785")}

      it 'returns error for invalid default gratuity percent' do
        expect(restaurant.save).to be_false
        expect(restaurant.errors.messages).to eq({
          :default_gratuity_percent=>["is invalid"]
        })
      end
    end

    context 'show suggested tips if signature enabled' do
      let!(:feature) { create :feature, control_value: 1, feature_owner: restaurant, feature_type: feature_type }
      let(:restaurant) { build(:restaurant)}
      subject { restaurant.valid? ; restaurant.errors }
      it 'passes validation if tips and signature are disabled' do
        restaurant.signature_enabled = false
        restaurant.show_suggested_tips = false
        expect(subject.keys).to be_empty
      end

      it 'passes validation if signature is not enabled' do
        restaurant.signature_enabled = false
        restaurant.show_suggested_tips = true
        expect(subject.keys).to be_empty
      end

      it 'requires suggested tips if signature is enabled' do
        restaurant.signature_enabled = true
        restaurant.show_suggested_tips = false
        expect(subject.keys).to eq [:show_suggested_tips]
        expect(subject[:show_suggested_tips]).to eq ["must be enabled if on-screen signature is enabled."]
      end

      context 'with disabled signature screen feature' do
        let(:restaurant) { build :restaurant, signature_enabled: true, show_suggested_tips: false }
        let!(:feature) { create :feature, control_value: 0, feature_type: feature_type }

        it 'allows suggested tips to be disabled' do
          expect(subject.keys).to be_empty
        end
      end
    end

    context 'signature enabled' do
      it 'defaults to sign on screen disabled' do
        expect(restaurant.signature_enabled).to be_false
      end
    end

    context 'custom tips enabled' do
      it 'defaults to custom tips enabled' do
        expect(restaurant.custom_tips_enabled).to be_true
      end
    end

    context 'suggested tip default' do
      it 'defaults to middle tip amount' do
        expect(restaurant.suggested_tip_default).to eq Enums::Restaurant::SuggestedTipDefault::MEDIUM_SUGGESTED_TIP
      end
    end

    context 'numericality' do
      let(:attributes) { [:default_gratuity_percent, :cc_server_tip_percent] }
      before do
        restaurant.update_attributes(default_gratuity_percent: value, cc_server_tip_percent: value)
      end

      context 'given a blank value' do
        let(:value) { nil }

        it 'allows a blank percentage' do
          expect(restaurant).to be_valid
        end
      end

      context 'given a value greater than 100' do
        let(:value) { 101 }

        it 'restaurant is invalid' do
          expect(restaurant).to be_invalid
        end

        it 'has errors for each attribute' do
          expect(restaurant.errors.keys).to eq attributes
        end
      end

      context 'given a value less than 0' do
        let(:value) { -2 }

        it 'restaurant is invalid' do
          expect(restaurant).to be_invalid
        end

        it 'has errors for each attribute' do
          expect(restaurant.errors.keys).to eq attributes
        end
      end
    end

    describe 'gratuity' do
      let(:restaurant) do
        create :live_restaurant,
          use_gratuity: use_gratuity,
          default_gratuity_percent: 5.0,
          default_gratuity_min_guest_count: 5
      end

      context 'restaurant uses gratuity' do
        let(:use_gratuity) { true }

        before { expect(restaurant).to be }
        before { expect(restaurant).to be_valid }

        it 'requires default_gratuity_percent' do
          restaurant.default_gratuity_percent = nil
          expect(restaurant).to be_invalid
        end

        it 'allows default_gratuity_min_guest_count to be blank' do
          restaurant.default_gratuity_min_guest_count = nil
          expect(restaurant).to be_valid
        end

        it 'requires default_gratuity_min_guest_count be > 0' do
          restaurant.default_gratuity_min_guest_count = -1
          expect(restaurant).to be_invalid
        end
      end

      context 'restaurant does not use gratuity' do
        let(:use_gratuity) { false }

        before { expect(restaurant).to be }
        before { expect(restaurant).to be_valid }

        it 'does not require default_gratuity_percent' do
          restaurant.default_gratuity_percent = nil
          expect(restaurant).to be_valid
        end

        it 'does not require default_gratuity_min_guest_count' do
          restaurant.default_gratuity_min_guest_count = nil
          expect(restaurant).to be_valid
        end
      end
    end

    context 'when showing suggested tips' do
      let(:show_suggested_tips) { true }
      let(:suggested_tip_percent_low) { 15.0 }
      let(:suggested_tip_percent_middle) { 18.0 }
      let(:suggested_tip_percent_high) { 20.0 }
      let(:restaurant) { build :restaurant,
        show_suggested_tips: show_suggested_tips,
        suggested_tip_percent_low: suggested_tip_percent_low,
        suggested_tip_percent_middle: suggested_tip_percent_middle,
        suggested_tip_percent_high: suggested_tip_percent_high }
      subject { restaurant.valid? ; restaurant.errors }

      context 'when low < middle < high' do
        it 'passes validations' do
          expect(subject).to be_empty
        end
      end

      context 'when low percentage is more than middle percentage' do
        let(:suggested_tip_percent_low) { 15.0 }
        let(:suggested_tip_percent_middle) { 15.0 }
        it 'fails validation on low percentage' do
          expect(subject[:suggested_tip_percent_low]).to eq ['must be < middle tip']
        end
      end

      context 'when middle percentage is more than high percentage' do
        let(:suggested_tip_percent_middle) { 20.0 }
        let(:suggested_tip_percent_high) { 20.0 }
        it 'fails validation on middle percentage' do
          expect(subject[:suggested_tip_percent_middle]).to eq ['must be < high tip']
        end
      end

      context 'when suggested tips are disabled' do
        let(:show_suggested_tips) { false }

        context 'when suggested tip percentages are not low < middle < high' do
          let(:suggested_tip_percent_low) { 20.0 }
          let(:suggested_tip_percent_middle) { 18.0 }
          let(:suggested_tip_percent_high) { 15.0 }

          [:suggested_tip_percent_low,
            :suggested_tip_percent_middle,
            :suggested_tip_percent_high].each do |attribute|
            it 'passes validation' do
              expect(subject[attribute]).to be_empty
            end
          end

          context 'with empty suggested tips' do
            let(:restaurant) { build :restaurant,
              show_suggested_tips: false,
              suggested_tip_percent_low: '',
              suggested_tip_percent_middle: '',
              suggested_tip_percent_high: ''
            }
            it 'does not validate blankness of tip amounts' do
              expect(subject.keys).to be_blank
            end
          end
        end

        context 'when suggested tip is not a whole number' do
          let(:suggested_tip_percent_low) { 15.55 }
          it 'passes whole number validation' do
            expect(subject[:suggested_tip_percent_low]).to be_empty
          end
        end
      end

      context 'defaults on restaurant creation' do
        let(:restaurant) { Restaurant.new }
        it 'defaults to valid 15, 18, 20' do
          expect(restaurant.suggested_tip_percent_low).to eq BigDecimal.new('15')
          expect(restaurant.suggested_tip_percent_middle).to eq BigDecimal.new('18')
          expect(restaurant.suggested_tip_percent_high).to eq BigDecimal.new('20')
        end
      end
    end

    context 'given a percentage' do
      [:suggested_tip_percent_low,
        :suggested_tip_percent_middle,
        :suggested_tip_percent_high,
        :default_gratuity_percent,
        :cc_server_tip_percent,
      ].each do |attribute|
        context 'when attribute is less than zero' do
          let(:restaurant) { restaurant = build :restaurant, show_suggested_tips: true, attribute => -1 }
          it 'fails greater than zero validation' do
            restaurant.valid?
            expect(restaurant.errors[attribute]).to include('must be greater than or equal to 0')
          end
        end

        context 'when percentage is larger than 100' do
          let(:restaurant) { restaurant = build :restaurant, show_suggested_tips: true, attribute => 101 }
          it 'fails maximum validation' do
            restaurant.valid?
            expect(restaurant.errors[attribute]).to include('must be less than or equal to 100')
          end
        end
      end
    end

    context 'given a suggested tip percentage' do
      [:suggested_tip_percent_low,
        :suggested_tip_percent_middle,
        :suggested_tip_percent_high,
      ].each do |attribute|
        subject { restaurant.valid? ; restaurant.errors }
        context 'when attribute is not a whole number' do
          let(:restaurant) { build :restaurant, show_suggested_tips: true, attribute => 20.1 }
          it 'fails whole number validation' do
            expect(subject[attribute]).to include('must be a whole number')
          end
        end

        context 'when attribute is a decimal with no fractions' do
          let(:restaurant) { build :restaurant, show_suggested_tips: true, attribute => 20.00 }
          it 'passes validation' do
            expect(subject[attribute]).to_not include 'must be a whole number'
          end
        end
      end
    end

    describe 'format of permalink' do
      subject { build(:restaurant, permalink: permalink)}

      context 'when permalink is blank' do
        let(:permalink) {}

        it "is valid to accomodate hoisted data" do
          expect(subject).to be_valid
        end
      end

      context 'when permalink is not blank' do
        context 'and contains letters, digits, dashes' do
          let(:permalink) { 'the-general22-great890'}

          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context 'and contains a special character' do
          let(:permalink) { 'foo.bar'}

          it "is invalid" do
            expect(subject).to be_invalid
          end
        end
      end
    end

    describe 'uniqueness of permalink' do
      before do
        @existing_restaurant = restaurant
      end

      subject { build(:restaurant, permalink: @existing_restaurant.permalink)}

      it "is not valid " do
        expect(subject).to_not be_valid
      end
    end

    describe 'timezone' do
      subject { build(:restaurant, timezone: timezone) }

      context 'when a timezone is not present' do
        context 'and is nil' do
          let(:timezone) { nil }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors.keys).to eq [:timezone]
          end
        end

        context 'and is an empty string' do
          let(:timezone) { ' ' }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors.keys).to eq [:timezone]
          end
        end
      end

      context 'when a timezone is present' do
        context 'and is not a valid timezone' do
          let(:timezone) { 'Pacific Time (US & Canada)' }

          it 'is valid' do
            expect(subject).to be_valid
          end
        end

        context 'given a valid timezone' do
          let(:timezone) { 'foo' }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors.keys).to eq [:timezone]
          end
        end
      end
    end

    describe 'required_version' do
      let(:restaurant) { build_stubbed(:restaurant) }
      let(:valid_versions) { %w(1.2.3 1.2.3-pre) }

      context 'with an invalid format' do
        let(:invalid_versions) { ['not_good', '1.2.3.4', '1', '1.2', nil, ''] }

        it 'is invalid' do
          invalid_versions.each do |version|
            restaurant.required_version = version

            expect(restaurant).not_to be_valid
            expect(restaurant.errors[:required_version]).not_to be_empty
          end
        end
      end

      context 'with a valid format' do
        it 'is valid' do
          valid_versions.each do |version|
            restaurant.required_version = version

            expect(restaurant).to be_valid
          end
        end
      end

      context 'when restaurant is live on 2.x platform' do
        before do
          restaurant.required_version = nil
          restaurant.required_version_enforced = required_version_enforced
        end

        context 'and required_version_enforced is true' do
          let(:required_version_enforced) { true }

          it 'requires a required_version' do
            expect(restaurant).to_not be_valid
          end

          context 'with values higher than the max allowed' do
            let(:max_allowed) { '1.1.1' }
            before do
              expect(ClientVersionSetting.update_default_new_restaurant_client_version(max_allowed)).to be_true
              expect(ClientVersionSetting.update_max_allowed_client_version(max_allowed)).to be_true
            end
            it 'is not valid' do
              valid_versions.each do |version|
                restaurant.required_version = version

                expect(restaurant).to_not be_valid
              end
            end
          end
        end

        context 'when required_version_enforced is not true' do
          let(:required_version_enforced) { [false, nil].sample }

          it 'does not require a required_version' do
            expect(restaurant).to be_valid
          end

          context 'with values higher than the max allowed' do
            let(:max_allowed) { '1.1.1' }
            before do
              expect(ClientVersionSetting.update_default_new_restaurant_client_version(max_allowed)).to be_true
              expect(ClientVersionSetting.update_max_allowed_client_version(max_allowed)).to be_true
            end
            it 'is valid' do
              valid_versions.each do |version|
                restaurant.required_version = version

                expect(restaurant).to be_valid
              end
            end
          end
        end
      end

      context 'when restaurant is not live on 2.x platform' do
        before do
          restaurant.required_version = nil
          restaurant.required_version_enforced = [true, false, nil].sample
          restaurant.migration_status = Enums::Restaurant::MigrationStatus::WHITELISTED_FOR_2_X
        end

        it 'does not require a required_version' do
          expect(restaurant).to be_valid
        end
      end
    end
  end

  describe "#to_param" do
    it 'uses permalink when present' do
      restaurant.update_attributes(permalink: "test")
      restaurant.to_param.should == "test"
    end

    it 'uses id when permalink is absent' do
      restaurant.update_attributes(name: nil, permalink: nil)
      restaurant.to_param.should == restaurant.id.to_s
    end
  end

  describe '#current_trading_day' do
    let!(:current_trading_day) { create :trading_day, {restaurant: restaurant, date: 1.days.ago}}
    let!(:past_trading_day) { create :trading_day, {restaurant: restaurant, date: 2.days.ago}}
    it { expect(restaurant.current_trading_day).to eq current_trading_day }
  end

  describe '#current_cashier_payments' do
    let!(:current_trading_day) { create :trading_day, {restaurant: restaurant, date: 1.days.ago}}
    let!(:past_trading_day) { create :trading_day, {restaurant: restaurant, date: 2.days.ago}}
    let!(:current_cashier_payments) {
      create_list :cashier_payment, 2, {
        restaurant: restaurant,
        trading_day: current_trading_day
      }
    }
    let!(:past_cashier_payments) {
      create_list :cashier_payment, 3, {
        restaurant: restaurant,
        trading_day: past_trading_day
      }
    }

    subject { restaurant.current_cashier_payments }
    it { expect(subject).to have(2).cashier_payments }
    it { expect(subject).to include(*current_cashier_payments) }
  end

  describe '.find_by_permalink_or_id' do
    subject { Restaurant.find_by_permalink_or_id permalink_or_id }

    context 'given a permalink of an existing restaurant' do
      let(:permalink_or_id) { restaurant.permalink }

      it 'returns the restaurant' do
        expect(subject).to eq restaurant
      end
    end

    context 'given a UUID of an existing restaurant' do
      let(:permalink_or_id) { restaurant.id.to_s }

      it 'returns the restaurant' do
        expect(subject).to eq restaurant
      end
    end

    context 'given an invalid UUID string' do
      let(:permalink_or_id) { 'x' * 36 }

      it 'raises an ActiveRecord::RecordNotFound' do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'given any other value' do
      let(:permalink_or_id) { 'foo' }

      it 'raises an ActiveRecord::RecordNotFound' do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe '.to_be_auto_closed' do
    subject { Restaurant.to_be_auto_closed }

    let(:to_be_auto_closed)               { create_list :to_be_auto_closed_restaurant, 3 }
    let(:to_be_auto_closed_in_the_future) { create_list :to_be_auto_closed_in_the_future, 3 }
    let(:auto_closing_trading_day)        { create_list :auto_closing_restaurant, 3 }
    let(:no_auto_close_restaurant)        { create :live_restaurant, auto_close: false }
    let(:no_ug_access_restaurant) do
      create :to_be_auto_closed_restaurant,
        migration_status: Enums::Restaurant::MigrationStatus::WITH_NO_UG_ACCESS
    end
    let(:locked_out_restaurant) do
      create :to_be_auto_closed_restaurant,
        migration_status: Enums::Restaurant::MigrationStatus::LOCKED_OUT
    end
    let(:not_to_be_auto_closed) do
      [no_ug_access_restaurant, locked_out_restaurant, no_auto_close_restaurant]
    end

    before do
      expect(not_to_be_auto_closed).to have(3).restaurants
      expect(to_be_auto_closed).to have(3).restaurants
      expect(auto_closing_trading_day).to have(3).restaurants
      expect(to_be_auto_closed_in_the_future).to have(3).restaurants
    end

    it 'returns 2.x restaurants with auto close active, a past auto-close date, and are not closing trading day' do
      expect(subject).to have(3).restaurants

      expect(subject).to include(*to_be_auto_closed)
      [to_be_auto_closed_in_the_future, not_to_be_auto_closed, auto_closing_trading_day].each do |restaurants|
        expect(subject).to_not include(*restaurants)
      end
    end
  end

  describe '.migrated_and_prelive_or_live' do
    let(:migrated_and_prelive_or_live_restaurants) { [@migrated_live_restaurants, @migrated_prelive_restaurants] }

    subject { Restaurant.migrated_and_prelive_or_live }

    before do
      create :live_restaurant, :whitelisted
      create :restaurant, :whitelisted, status: Enums::Restaurant::Status::PRELIVE
      @migrated_live_restaurants = create :live_restaurant, :live_on_2_x
      @migrated_prelive_restaurants = create :restaurant, :live_on_2_x, status: Enums::Restaurant::Status::PRELIVE
    end

    it 'only includes migrated restaurants migrated with a status of prelive or live' do
      expect(subject.size).to eq migrated_and_prelive_or_live_restaurants.size
      expect(subject).to match_array(migrated_and_prelive_or_live_restaurants)
    end
  end

  describe '#no_signature_required_small_check_amount' do
    it 'always returns 25 dollars in cents' do
      expect(restaurant.no_signature_required_small_check_amount).to eq 2500
    end
  end

  describe '#lowest_available_device_number' do
    context 'given multiple devices are created on the same restaurant' do
      let(:pos_devices) { create_list :pos_device, 3, restaurant_id: restaurant.id.to_s }
      let(:new_device)  { build :pos_device, restaurant_id: restaurant.id.to_s }

      before do
        expect(restaurant.pos_devices).to include pos_devices.sample
      end

      it 'increments the order to 6' do
        expect { new_device.save! }
          .to change(new_device, :order)
          .to(3)
      end

      context 'and one of them is removed' do
        let(:removed_device) { pos_devices.sample }

        before { removed_device.destroy }

        it 'finds the lowest available order number' do
          expect{ new_device.save! }
            .to change(new_device, :order)
            .to(removed_device.order)
        end
      end

      context 'and existing pos_devices with nil order' do
        let(:pos_devices) { create_list :pos_device, 2, restaurant_id: restaurant.id.to_s }

        before do
          pos_devices.each do |device|
            device.update_attributes(order: nil)
          end
        end

        it 'increments the order of the new device only' do
          expect{ new_device.save! }
          .to change(new_device, :order)
          .to(0)
        end
      end
    end

    context 'given two restaurants and separate devices' do
      let(:new_restaurant) { create :live_restaurant }
      let(:first_device)   { create :pos_device, restaurant: restaurant }
      let(:second_device)  { create :pos_device, restaurant: new_restaurant }
      let(:third_device)   { create :pos_device, restaurant: restaurant.reload }

      it 'increments the order scoped to each restaurant' do
        expect(first_device.order).to eq 0
        expect(second_device.order).to eq 0
        expect(third_device.order).to eq 1
      end
    end
  end

  describe '#next_available_check_number', :checks do
    it 'calls rincr' do
      $redis.should_receive(:rincr).with(restaurant.check_number_counter_key, Restaurant::MAX_CHECK_NUMBER)
      restaurant.next_available_check_number
    end
  end

  describe '#can_be_authorized' do
    let(:restaurant) {create :live_restaurant, status: status, migration_status: migration_status }
    subject {restaurant.can_be_authorized}

    context 'when migration_status is locked_out' do
      let(:migration_status) { Enums::Restaurant::MigrationStatus::LOCKED_OUT }

      context 'when status is deactivated' do
        let(:status) { Enums::Restaurant::Status::DEACTIVATED }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { Enums::Restaurant::Status::LIVE }

        it 'returns false' do
          expect(subject).to be false
        end
      end
    end

    context 'when migration_status is with_no_ug_access' do
      let(:migration_status) { Enums::Restaurant::MigrationStatus::WITH_NO_UG_ACCESS }

      context 'when status is deactivated' do
        let(:status) { Enums::Restaurant::Status::DEACTIVATED }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { Enums::Restaurant::Status::LIVE }

        it 'returns false' do
          expect(subject).to be true
        end
      end
    end

    context 'when migration_status is live_on_2_x' do
      let(:migration_status) { Enums::Restaurant::MigrationStatus::LIVE_ON_2_X }

      context 'when status is deactivated' do
        let(:status) { Enums::Restaurant::Status::DEACTIVATED }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { Enums::Restaurant::Status::LIVE }

        it 'returns false' do
          expect(subject).to be true
        end
      end
    end

  end

  describe '#migrated_and_not_deactivated' do
    let(:restaurant) {create :live_restaurant, status: status, migration_status: migration_status }
    subject { restaurant.migrated_and_not_deactivated }

    context 'when migration_status is live_on_2_x' do
      let(:migration_status) { 3 }

      context 'when status is deactivated' do
        let(:status) { 3 }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { 1 }

        it 'returns true' do
          expect(subject).to be true
        end
      end
    end

    context 'when migration_status is not live_on_2_x' do
      let(:migration_status) { 4 }

      context 'when status is deactivated' do
        let(:status) { 3 }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { 1 }

        it 'returns false' do
          expect(subject).to be false
        end
      end
    end
  end

  describe "#can_hit_uber_gateway" do
    let(:restaurant) {create :live_restaurant, status: status, migration_status: migration_status }
    subject {restaurant.can_hit_uber_gateway}

    context 'when migration_status is locked_out' do
      let(:migration_status) { Enums::Restaurant::MigrationStatus::LOCKED_OUT }

      context 'when status is deactivated' do
        let(:status) { Enums::Restaurant::Status::DEACTIVATED }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { Enums::Restaurant::Status::LIVE }

        it 'returns false' do
          expect(subject).to be false
        end
      end
    end

    context 'when migration_status is with_no_ug_access' do
      let(:migration_status) { Enums::Restaurant::MigrationStatus::WITH_NO_UG_ACCESS }

      context 'when status is deactivated' do
        let(:status) { Enums::Restaurant::Status::DEACTIVATED }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { Enums::Restaurant::Status::LIVE }

        it 'returns false' do
          expect(subject).to be false
        end
      end
    end

    context 'when migration_status is live_on_2_x' do
      let(:migration_status) { Enums::Restaurant::MigrationStatus::LIVE_ON_2_X }

      context 'when status is deactivated' do
        let(:status) { Enums::Restaurant::Status::DEACTIVATED }
        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when status is not deactivated' do
        let(:status) { Enums::Restaurant::Status::LIVE }

        it 'returns false' do
          expect(subject).to be true
        end
      end
    end
  end

  describe '#advance_auto_close_date' do
    let(:timezone) { "Pacific Time (US & Canada)" }
    let(:restaurant) { build :restaurant, timezone: timezone, auto_close_date: auto_close_date }
    let(:auto_close_date_in_local_time) { restaurant.reload.auto_close_date_in_local_time.inspect }

    before { restaurant.advance_auto_close_date }

    context 'normal day away from day light saving date' do
      let(:auto_close_date) { Time.parse("Fri, 06 Mar 2015 02:10:00 PST -08:00") }

      it 'advances the auto close date by one day in local time' do
        expect(auto_close_date_in_local_time).to eq("Sat, 07 Mar 2015 02:10:00 PST -08:00")
      end
    end

    context 'daylight saving transition date 2AM-3AM' do
      let(:auto_close_date) { Time.parse("Sat, 07 Mar 2015 02:10:00 PST -08:00") }

      it 'skips an hour to an existing local time' do
        expect(auto_close_date_in_local_time).to eq("Sun, 08 Mar 2015 03:10:01 PDT -07:00")
      end
    end

    context 'the day after daylight saving transition date' do
      let(:auto_close_date) { Time.parse("Sun, 08 Mar 2015 03:10:01 PDT -07:00") }

      it 'roll backs an hour to use user-designated hour' do
        expect(auto_close_date_in_local_time).to eq("Mon, 09 Mar 2015 02:10:00 PDT -07:00")
      end
    end
  end

  describe '#required_version_enforced_atall' do
    let(:restaurant) {
      create :live_restaurant,
        required_version_enforced: required_version_enforced,
        required_version: '2.3.0'
    }

    subject { restaurant.required_version_enforced_atall }

    context 'when required_version_enforced is not present' do
      let(:required_version_enforced) { nil }
      let(:feature_flag) { [true, false].sample }

      before { restaurant.stub(:is_feature_on).with('required_version_enforced').and_return(feature_flag) }

      it 'has the value specified by the feature flag' do
        expect(subject).to eq feature_flag
      end
    end

    context 'when required_version_enforced is present' do
      let(:required_version_enforced) { [true, false].sample }

      it 'has the value specified required_version_enforced' do
        expect(subject).to eq required_version_enforced
      end
    end
  end

  describe '#required_version_enforced_atall=' do
    let(:restaurant) {
      create :live_restaurant,
             required_version_enforced: [nil, true, false].sample,
             required_version: '2.3.0'
    }
    let(:new_required_version_enforced) { [true, false].sample }

    before do
      restaurant.update_attributes(required_version_enforced_atall: new_required_version_enforced)
    end

    it 'resets required_version_enforced correctly' do
      expect(restaurant.reload.required_version_enforced).to eq new_required_version_enforced
      expect(restaurant.reload.required_version_enforced_atall).to eq new_required_version_enforced
    end
  end

  describe 'uber gateway setup' do
    let(:instance) { create :live_restaurant }
    let(:merchant_profile) { instance.merchant_profile }
    let(:expected_credentials) {{
        merchant_key: merchant_profile.ug_merchant_key,
        merchant_password: merchant_profile.ug_merchant_password
    }}

    it_behaves_like 'bpro uber gateway credentials'
    it_behaves_like 'a uber gateway config'
    it_behaves_like 'a uber gateway processor'
  end

  describe '#app_update_url' do
    let(:restaurant) { create :restaurant, app_update_url: app_update_url }

    context 'when the restaurant has an app_update_url' do
      let(:app_update_url) { "http://www.lookatmeimaurl.com" }

      it 'returns the url from the column' do
        expect(restaurant.app_update_url).to eq(app_update_url)
      end
    end

    context 'when the restaurant has no app_update_url' do
      let(:app_update_url) { nil }

      it 'returns the default url' do
        expect(restaurant.app_update_url).to eq(AppConfig.properties.default_app_update_url)
      end
    end
  end

  describe '#required_version_in_range?' do
    let(:restaurant) { build :restaurant, required_version: required_version }
    let(:lower) { '2.4.1' }
    let(:upper) { '2.4.4' }

    subject { restaurant.required_version_in_range?(lower, upper) }

    context 'when required_version is in the range' do
      let(:required_version) { '2.4.3' }

      it 'returns true' do
        expect(subject).to be_true
      end
    end

    context 'when required_version is not in the range' do
      let(:required_version) { '2.4.5' }

      it 'returns false' do
        expect(subject).to be_false
      end
    end
  end

  describe '#sanitize_admin_email!' do
    shared_examples_for 'an invalid email detected' do
      before { subject }

      it 'returns false' do
        expect(subject).to be_false
      end
    end

    shared_examples_for 'sanitizing admin_email' do
      before { subject }

      it 'returns true' do
        expect(subject).to be_true
      end

      it 'returns true' do
        expect(restaurant.reload.admin_email).to eq sanitized_admin_email
      end
    end

    let(:restaurant) { create :restaurant, admin_email: admin_email }

    subject { restaurant.sanitize_admin_email! }

    context 'when admin_email is nil' do
      let(:admin_email) { nil }

      it_behaves_like 'an invalid email detected'
    end

    context 'when admin_email is blank' do
      let(:admin_email) { ' ' }

      it_behaves_like 'an invalid email detected'
    end

    context 'when admin_email does not contain a @' do
      let(:admin_email) { 'foo.bar' }

      it_behaves_like 'an invalid email detected'
    end

    context 'when admin_email does not contain a dot' do
      let(:admin_email) { 'foo@bar' }

      it_behaves_like 'an invalid email detected'
    end

    context 'when admin_email is a list of email addresses ' do
      let(:sanitized_admin_email) { 'foo1@bar.com,foo2@bar.com,foo3@bar.com' }

      context 'seperated by a comma' do
        let(:admin_email) { 'foo1@bar.com, foo2@bar.com,foo3@bar.com' }

        it_behaves_like 'sanitizing admin_email'
      end

      context 'seperated by an ampersand' do
        let(:admin_email) { 'foo1@bar.com & foo2@bar.com&foo3@bar.com' }

        it_behaves_like 'sanitizing admin_email'
      end

      context 'seperated by a semicolon' do
        let(:admin_email) { 'foo1@bar.com; foo2@bar.com;foo3@bar.com' }

        it_behaves_like 'sanitizing admin_email'
      end

      context 'seperated by a whitespace' do
        let(:admin_email) { 'foo1@bar.com foo2@bar.com foo3@bar.com' }

        it_behaves_like 'sanitizing admin_email'
      end
    end

    context 'when admin_email contains one email address ' do
      let(:sanitized_admin_email) { 'foo@bar.com' }

      context 'followed by a comma' do
        let(:admin_email) { 'foo@bar.com,' }

        it_behaves_like 'sanitizing admin_email'
      end

      context 'followed by a ampersand' do
        let(:admin_email) { 'foo@bar.com &' }

        it_behaves_like 'sanitizing admin_email'
      end

      context 'followed by a semicolon' do
        let(:admin_email) { 'foo@bar.com;' }

        it_behaves_like 'sanitizing admin_email'
      end

      context 'followed by a whitesapce' do
        let(:admin_email) { 'foo@bar.com ' }

        it_behaves_like 'sanitizing admin_email'
      end

      context 'followed by nothing' do
        let(:admin_email) { 'foo@bar.com' }

        it_behaves_like 'sanitizing admin_email'

        it 'does not update the email address' do
          expect(restaurant).to_not receive(:update_column)
          subject
        end
      end
    end
  end

  describe 'relationships' do
    let(:client_option) { create :client_option, restaurant: restaurant }
    it 'has a two-way relationship' do
      expect(restaurant.client_options).to eq [client_option]
      expect(client_option.restaurant).to eq restaurant
    end
  end
end
