require File.expand_path('../test_helper', __FILE__)
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'rest-client'

class TestEligible < Test::Unit::TestCase
  include Mocha

  context "Version" do
    should "have a version number" do
      assert_not_nil Eligible::VERSION
    end
  end

  context "General API" do
    setup do
      Eligible.api_key = "TEST"
      @mock = mock
      Eligible.mock_rest_client = @mock
    end

    teardown do
      Eligible.mock_rest_client = nil
      Eligible.api_key = nil
    end

    should "not specifying api credentials should raise an exception" do
      Eligible.api_key = nil
      assert_raises Eligible::AuthenticationError do
        Eligible::Plan.get({})
      end
    end

    should "specifying invalid api credentials should raise an exception" do
      Eligible.api_key = "invalid"
      response = test_response(test_invalid_api_key_error, 401)
      assert_raises Eligible::AuthenticationError do
        @mock.expects(:get).once.raises(RestClient::ExceptionWithResponse.new(response, 401))
        Eligible::Plan.get({})
      end
    end
  end

  context "Plan" do
    setup do
      Eligible.api_key = "TEST"
      @mock = mock
      Eligible.mock_rest_client = @mock
    end

    teardown do
      Eligible.mock_rest_client = nil
      Eligible.api_key = nil
    end

    should "return an error if no params are supplied" do
      params = {}
      response = test_response(test_plan_missing_params)
      @mock.expects(:get).returns(response)
      plan = Eligible::Plan.get(params)
      assert_not_nil plan.error
    end

    should "return plan information if valid params are supplied" do
      params = {
        :payer_name => "Aetna",
        :payer_id   => "000001",
        :service_provider_last_name => "Last",
        :service_provider_first_name => "First",
        :service_provider_NPI => "1928384219",
        :subscriber_id => "W120923801",
        :subscriber_last_name => "Austen",
        :subscriber_first_name => "Jane",
        :subscriber_dob => "1955-12-14"
      }
      response = test_response(test_plan)
      @mock.expects(:get).returns(response)
      plan = Eligible::Plan.get(params)
      assert_nil plan.error
      assert_not_nil plan.all
    end

    should "return the right subsets of the data when requested" do
      params = {
        :payer_name => "Aetna",
        :payer_id   => "000001",
        :service_provider_last_name => "Last",
        :service_provider_first_name => "First",
        :service_provider_NPI => "1928384219",
        :subscriber_id => "W120923801",
        :subscriber_last_name => "Austen",
        :subscriber_first_name => "Jane",
        :subscriber_dob => "1955-12-14"
      }
      response = test_response(test_plan)
      @mock.expects(:get).returns(response)
      plan = Eligible::Plan.get(params)

      assert_not_nil  plan.all[:primary_insurance]
      assert_not_nil  plan.status[:coverage_status]
      assert_nil      plan.status[:deductible_in_network]
      assert_not_nil  plan.deductible[:deductible_in_network]
      assert_nil      plan.deductible[:balance]
      assert_not_nil  plan.dates[:primary_insurance][:plan_begins]
      assert_nil      plan.dates[:deductible_in_network]
      assert_not_nil  plan.balance[:balance]
      assert_nil      plan.balance[:deductible_in_network]
      assert_not_nil  plan.stop_loss[:stop_loss_in_network]
      assert_nil      plan.stop_loss[:deductible_in_network]
    end
  end

  context "Service" do
    setup do
      Eligible.api_key = "TEST"
      @mock = mock
      Eligible.mock_rest_client = @mock
    end

    teardown do
      Eligible.mock_rest_client = nil
      Eligible.api_key = nil
    end

    should "return an error if no params are supplied" do
      params = {}
      response = test_response(test_service_missing_params)
      @mock.expects(:get).returns(response)
      service = Eligible::Service.get(params)
      assert_not_nil service.error
    end

    should "return eligibility information if valid params are supplied" do
      params = {
        :payer_name => "Aetna",
        :payer_id   => "000001",
        :service_provider_last_name => "Last",
        :service_provider_first_name => "First",
        :service_provider_NPI => "1928384219",
        :subscriber_id => "W120923801",
        :subscriber_last_name => "Austen",
        :subscriber_first_name => "Jane",
        :subscriber_dob => "1955-12-14"
      }
      response = test_response(test_service)
      @mock.expects(:get).returns(response)
      service = Eligible::Service.get(params)
      assert_nil service.error
      assert_not_nil service.all
    end

    should "return the right subsets of the data when requested" do
      params = {
        :payer_name => "Aetna",
        :payer_id   => "000001",
        :service_provider_last_name => "Last",
        :service_provider_first_name => "First",
        :service_provider_NPI => "1928384219",
        :subscriber_id => "W120923801",
        :subscriber_last_name => "Austen",
        :subscriber_first_name => "Jane",
        :subscriber_dob => "1955-12-14"
      }
      response = test_response(test_service)
      @mock.expects(:get).returns(response)
      service = Eligible::Service.get(params)

      assert_not_nil  service.all[:service_begins]
      assert_not_nil  service.visits[:visits_in_network]
      assert_nil      service.visits[:copayment_in_network]
      assert_not_nil  service.copayment[:copayment_in_network]
      assert_nil      service.copayment[:visits_in_network]
      assert_not_nil  service.coinsurance[:coinsurance_in_network]
      assert_nil      service.coinsurance[:visits_in_network]
      assert_not_nil  service.deductible[:deductible_in_network]
      assert_nil      service.deductible[:visits_in_network]
    end
  end

  context "Demographic" do
    setup do
      Eligible.api_key = "TEST"
      @mock = mock
      Eligible.mock_rest_client = @mock
    end

    teardown do
      Eligible.mock_rest_client = nil
      Eligible.api_key = nil
    end

    should "return an error if no params are supplied" do
      params = {}
      response = test_response(test_demographic_missing_params)
      @mock.expects(:get).returns(response)
      demographic = Eligible::Demographic.get(params)
      assert_not_nil demographic.error
    end

    should "return demographic information if valid params are supplied" do
      params = {
        :payer_name => "Aetna",
        :payer_id   => "000001",
        :service_provider_last_name => "Last",
        :service_provider_first_name => "First",
        :service_provider_NPI => "1928384219",
        :subscriber_id => "W120923801",
        :subscriber_last_name => "Austen",
        :subscriber_first_name => "Jane",
        :subscriber_dob => "1955-12-14"
      }
      response = test_response(test_demographic)
      @mock.expects(:get).returns(response)
      demographic = Eligible::Demographic.get(params)
      assert_nil demographic.error
      assert_not_nil demographic.all
    end

    should "return the right subsets of the data when requested" do
      params = {
        :payer_name => "Aetna",
        :payer_id   => "000001",
        :service_provider_last_name => "Last",
        :service_provider_first_name => "First",
        :service_provider_NPI => "1928384219",
        :subscriber_id => "W120923801",
        :subscriber_last_name => "Austen",
        :subscriber_first_name => "Jane",
        :subscriber_dob => "1955-12-14"
      }
      response = test_response(test_demographic)
      @mock.expects(:get).returns(response)
      demographic = Eligible::Demographic.get(params)

      assert_not_nil  demographic.all[:timestamp]
      assert_not_nil  demographic.zip[:zip]
      assert_nil      demographic.zip[:group_id]
      assert_not_nil  demographic.employer[:group_id]
      assert_nil      demographic.employer[:zip]
      assert_not_nil  demographic.address[:address]
      assert_nil      demographic.address[:group_id]
      assert_not_nil  demographic.dob[:dob]
      assert_nil      demographic.dob[:address]
    end
  end

  context "Claim" do
    setup do
      Eligible.api_key = "TEST"
      @mock = mock
      Eligible.mock_rest_client = @mock
    end

    teardown do
      Eligible.mock_rest_client = nil
      Eligible.api_key = nil
    end

    should "return an error if no params are supplied" do
      params = {}
      response = test_response(test_claim_missing_params)
      @mock.expects(:get).returns(response)
      claim = Eligible::Claim.get(params)
      assert_not_nil claim.error
    end

    should "return claim information if valid params are supplied" do
      params = {
        :tbd => true
      }
      response = test_response(test_claim)
      @mock.expects(:get).returns(response)
      claim = Eligible::Claim.get(params)
      assert_nil claim.error
      assert_not_nil claim.status
    end
  end
end
