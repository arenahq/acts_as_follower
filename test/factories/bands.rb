FactoryBot.define do
  factory :oasis, class: Band do
    name { 'Oasis' }
  end

  factory :metallica, class: Band do
    name { 'Metallica' }
  end

  factory :green_day, :class => Band::Punk do
    name { 'Green Day' }
  end

  factory :blink_182, :class => Band::Punk::PopPunk do
    name { 'Blink 182' }
  end
end
