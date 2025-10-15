function groupAndExtractLatest(records) {
  // Step 1: Group records by animal_tag
  const grouped = records.reduce((acc, record) => {
    const tag = record.animal_tag;
    if (!acc[tag]) {
      acc[tag] = {
        animal_name: record.animal_name,
        production_dates: [],
        total_daily_productions: [],
      };
    }

    acc[tag].production_dates.push(new Date(record.production_date));
    acc[tag].total_daily_productions.push(record.total_daily_production);

    return acc;
  }, {});

  // Step 2: Sort each group's records by date and keep only last 15
  for (const tag in grouped) {
    // Combine dates and productions into one array for sorting
    const combined = grouped[tag].production_dates.map((date, i) => ({
      date,
      production: grouped[tag].total_daily_productions[i],
    }));

    // Sort descending by date
    combined.sort((a, b) => b.date - a.date);

    // Slice last 15
    const latest15 = combined.slice(0, 15);

    // Rebuild arrays
    grouped[tag].production_dates = latest15.map((item) =>
      item.date.toLocaleDateString()
    );
    grouped[tag].total_daily_productions = latest15.map(
      (item) => item.production
    );
  }

  return grouped;
}

function getChartData(animals) {
  const xValues = [];
  const yValues = [];
  animals.forEach((animal) => {
    xValues.push(animal.animal_name + "-" + animal.animal_tag);
    yValues.push(animal.total_production);
  });
  return [xValues, yValues];
}

module.exports = { groupAndExtractLatest, getChartData };
