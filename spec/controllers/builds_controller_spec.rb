require 'spec_helper'

describe BuildsController, type: :request do
  let(:project) { projects(:one) }
  let(:build) { builds(:one) }

  it "should get index" do
    get "/builds" 
    expect(assigns :builds.to_s).not_to be_nil
    expect(response.status == 200)
  end

  it "should get new" do
    get "/builds/new" 
    b = assigns :build.to_s
    expect(b.branch).to eq('master')
    expect(response.status == 200)
  end

  xit "should create build" do
    expect(BuildWorker).to receive(:perform_async)
    expect do
      post "/builds", params: { build: { project_id: project, branch: 'some-branch' } }
    end.to change { Build.count }.by(1)

    b = assigns :build.to_s

    expect(not(b.nil?))
    expect(b.project.id == project.id)
    expect(b.branch == 'some-branch')
    expect(response).to redirect_to(build_path(b))
  end

  xit "should show build" do
    get :show, id: build

    expect(assigns :build).to eq(build)
    expect(response).to be_success
  end

  xit "should destroy build" do
    expect { delete :destroy, id: build.id }.to change { Build.count }.by(-1)

    expect(response).to redirect_to(builds_path)
  end
end
