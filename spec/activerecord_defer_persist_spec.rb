require "logger"
require "activerecord_defer_persist/defer_persist"
require "active_record"

class CreateTables < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |table|
      table.string :name
    end
    create_table :teams do |table|
      table.string :name
    end
    create_table :memberships do |table|
      table.references :user
      table.references :team
    end
  end
end

class User < ActiveRecord::Base
  has_many :memberships
  has_many :teams, through: :memberships
end

class Team < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships
end

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
end

RSpec.describe ActiverecordDeferPersist::Concern do
  before(:all) do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Migration.suppress_messages { CreateTables.migrate(:up) }
  end

  after(:all) do
    ActiveRecord::Migration.suppress_messages { CreateTables.migrate(:down) }
  end

  before(:each) do
    User.delete_all
    Membership.delete_all
    Team.delete_all
  end

  let!(:user1) { User.create!(id: 1, name: "Jane") }
  let!(:user2) { User.create!(id: 2, name: "Marco") }
  let!(:user3) { User.create!(id: 3, name: "Jungyoon") }

  def include_defer_persist(team)
    team.singleton_class.include(described_class)
    team.singleton_class.defer_persist(:users)
  end

  describe "#user_ids=" do
    context "without defer_persist" do
      it "#user_ids= persists to the db" do
        team = Team.create(name: "Lakers", user_ids: [])
        team.user_ids = [1, 2]
        expect(Membership.count).to eq(2)
        expect(Team.find(team.id).user_ids).to contain_exactly(1, 2)
      end
    end

    context "with defer_persist" do
      specify "basic usage" do
        team = Team.create(user_ids: [1])
        include_defer_persist(team)
        team.user_ids = [1, 2, 3]
        expect(Team.find(team.id).user_ids).to contain_exactly(1) # it has not persisted to the db
        expect(team.user_ids).to contain_exactly(1, 2, 3) # the getter returns the unpersisted changes
        expect(team.users).to contain_exactly(user1, user2, user3) # same for the hydrated getter
        team.save
        expect(Team.find(team.id).user_ids).to contain_exactly(1, 2, 3) # it is now persisted to the db
        expect(team.user_ids).to contain_exactly(1, 2, 3)
      end
    end
  end


  describe "#reload" do
    it "clears unpersisted changes" do
      team = Team.create(user_ids: [1])
      include_defer_persist(team)
      team.user_ids = [1, 2, 3]
      expect(team.user_ids).to contain_exactly(1, 2, 3) # the getter returns the unpersisted changes
      expect(team.users).to contain_exactly(user1, user2, user3)
      team.reload
      expect(team.user_ids).to contain_exactly(1)
      expect(team.users).to contain_exactly(user1)
    end
  end

  context "unrelated changes (no has many ids changes)" do
    it "does not change has many association" do
      team = Team.create(user_ids: [1])
      include_defer_persist(team)
      team.name = "Aprèm"
      team.save
      team.reload
      expect(team.name).to eq("Aprèm")
      expect(team.user_ids).to contain_exactly(1)
    end
  end
end

