FactoryBot.define do
  factory :jon, class: User do
    name { 'Jon' }
  end

  factory :sam, class: User do
    name { 'Sam' }
   end

  factory :bob, class: User do
    name { 'Bob' }
  end

  factory :user, class: User do
    name { 'Another' }
  end
end
