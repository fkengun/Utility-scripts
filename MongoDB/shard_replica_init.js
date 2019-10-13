rs.initiate(
{
	_id : "shardreplica01",
	members: [		{ _id : 0, host : "ares-comp-27-40g" },
		{ _id : 1, host : "ares-comp-28-40g" },
		{ _id : 2, host : "ares-comp-29-40g" },
		{ _id : 3, host : "ares-comp-30-40g" },
		{ _id : 4, host : "ares-comp-31-40g" },
		{ _id : 5, host : "ares-comp-32-40g" }
	]
}
)