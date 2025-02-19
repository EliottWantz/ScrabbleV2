package user

type User struct {
	ID               string      `bson:"_id,omitempty" json:"id,omitempty"`
	Username         string      `bson:"username" json:"username,omitempty"`
	HashedPassword   string      `bson:"password" json:"-"`
	Email            string      `bson:"email" json:"email,omitempty"`
	Avatar           Avatar      `bson:"avatar" json:"avatar,omitempty"`
	Preferences      Preferences `bson:"preferences" json:"preferences"`
	JoinedChatRooms  []string    `bson:"joinedChatRooms" json:"joinedChatRooms"`
	JoinedDMRooms    []string    `bson:"joinedDMRooms" json:"joinedDMRooms"`
	JoinedGame       string      `bson:"joinedGame" json:"joinedGame"`
	JoinedTournament string      `bson:"joinedTournament" json:"joinedTournament"`
	Friends          []string    `bson:"friends" json:"friends"`
	PendingRequests  []string    `bson:"pendingRequests" json:"pendingRequests"`
	Summary          Summary     `bson:"summary" json:"summary,omitempty"`
	IsConnected      bool        `bson:"isConnected" json:"isConnected"`
}
