require 'test_helper'

class Api::SheltersControllerTest < ActionDispatch::IntegrationTest

  test "Using If-Modified-Since will 304" do
    max = Shelter.maximum("updated_at")
    get "/api/v1/shelters", headers: {
      "If-Modified-Since" => max.rfc2822
    }
    assert_equal 304, response.status
  end

  test "returns all shelters" do
    count = Shelter.count
    get "/api/v1/shelters"
    json = JSON.parse(response.body)
    assert_equal count, json["shelters"].length
    assert_equal count, json["meta"]["result_count"]
  end

  test "Geo and limits work" do
    count = Shelter.count
    get "/api/v1/shelters?lat=30.0071377&lon=-95.3797033&limit=1"
    json = JSON.parse(response.body)
    assert_equal shelters(:lonestar).shelter, json["shelters"].first["shelter"]
    assert_equal 1, json["shelters"].length
    assert_equal 1, json["meta"]["result_count"]
  end

  test "filters are returned" do
    count = Shelter.where(accepting: true).count
    get "/api/v1/shelters?accepting=true"
    json = JSON.parse(response.body)
    assert_equal count, json["shelters"].length
    assert_equal count, json["meta"]["result_count"]
    assert_equal "true", json["meta"]["filters"]["accepting"]
  end

  test "shelters are not returned after they are archived" do
    archived = Shelter.where(active: false).count
    active = Shelter.where(active: !false).count
    count = active - archived
    get "/api/v1/shelters"
    json = JSON.parse(response.body)
    assert_equal count, json["shelters"].length
  end
end
