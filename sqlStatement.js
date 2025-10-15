function getProductionRecordsForFarmer(farmer_id) {
  return `SELECT 
    Animal.animal_tag,
    Animal.name as animal_name,
    MilkProduction.production_date,
    SUM(MilkProduction.quantity) as total_daily_production,
    COUNT(*) as milking_sessions,
    Farmers.farm_name,
    MilkProduction.unit
FROM MilkProduction 
JOIN Animal ON MilkProduction.animal_id = Animal.animal_tag
JOIN Farmers ON Animal.owner_id = Farmers.farmer_id
WHERE Farmers.farmer_id = ${farmer_id}
GROUP BY Animal.animal_tag, Animal.name, MilkProduction.production_date, Farmers.farm_name, MilkProduction.unit
ORDER BY MilkProduction.production_date ASC`;
}

function getAnimalsProductionsForFarmer(farmer_id) {
  return `SELECT 
    f.farm_name,
    f.fullname AS farmer_name,
    a.animal_tag,
    a.name AS animal_name,
    SUM(mp.quantity) AS total_production,
    mp.unit
FROM Farmers f
JOIN Animal a ON f.farmer_id = a.owner_id
JOIN MilkProduction mp ON a.animal_tag = mp.animal_id
WHERE f.farmer_id = ${farmer_id}
GROUP BY f.farm_name, f.fullname, a.animal_tag, a.name, mp.unit
`;
}
module.exports = {
  getProductionRecordsForFarmer,
  getAnimalsProductionsForFarmer,
};
