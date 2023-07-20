require 'spec_helper'

describe ProjectsController, type: :request do
  let(:project) { projects(:one) }

  it "should get new" do
    get "/projects/new"
    expect(response.status == 200)
    expect(assigns :project.to_s).not_to be_nil
  end

  it "should create project" do
    expect do
      post "/projects", params: {
        project: { repo: 'foo/bar.git', github_host: 'github.internal.com' }
      }
    end.to change { Project.count }.by(1)

    p = assigns :project
    expect(p.repo).to eq('foo/bar.git')
    expect(p.github_host).to eq('github.internal.com')

    expect(response).to redirect_to(project_path(p))
  end

  it "should show project" do
    get "/projects/#{project.id}" 
    expect(assigns :project).to eq(project)
    expect(response.status == 200)
  end

  it "should edit project" do
    get "/projects/#{project.id}/edit"
    expect(assigns :project).to eq(project)
    expect(response.status == 200)
  end

  describe "github host choices" do
    let(:other_host) { projects(:two) }

    context "without ENTERPRISE_HOSTS" do
      before do
        allow(ENV).to receive(:[]).with('ENTERPRISE_HOSTS').and_return(nil)
      end

      it "shouldn't offer a choice of github host" do
        get "/projects/new" 
        expect(assigns :hosts).to eq(["github.com"])
      end

      it "offers a choice if the project already specifies a different host" do
        get "/projects/#{other_host.id}/edit" 
        expect(assigns :hosts).to eq(['github.com', other_host.github_host])
      end
    end

    context "with ENTERPRISE_HOSTS" do
      before do
        allow(ENV).to receive(:[]).with('ENTERPRISE_HOSTS').and_return(
          'github.starship-enterprise.com,github.galactica.com')
      end

      it "should offer a choice of github hosts" do
        get "/projects/new" 
        expect(assigns :hosts).to eq(%w{
          github.starship-enterprise.com
          github.galactica.com
          github.com
        })
      end

      it "offers the original host as a choice on existing projects" do
        get "/projects/#{other_host.id}/edit" 
        expect(assigns :hosts).to eq([
          'github.starship-enterprise.com',
          'github.galactica.com',
          'github.com',
          other_host.github_host])
      end
    end
  end

  it "should update project" do
    #patch :update, id: project, project: {
    patch "/projects/#{project.id}", params: {
      project: {
        repo: 'something/different.git',
        github_host: 'github.something.com'
      }
    }

    #p = assigns :project.to_s
    #expect(p.repo).to eq('something/different.git')
    #expect(p.github_host).to eq('github.something.com')

    #assert_redirected_to project_path(assigns(:project))
  end

  # on ne detruit pas de projet
  #it "should destroy project" do
  #  expect { delete :destroy, id: project }.to change { Project.count }.by(-1)

  #  expect(response).to redirect_to(root_path)
  #end
end
