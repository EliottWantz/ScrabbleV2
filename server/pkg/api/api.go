package api

import (
	"errors"
	"time"

	"scrabble/config"
	"scrabble/pkg/api/auth"
	"scrabble/pkg/api/game"
	"scrabble/pkg/api/room"
	"scrabble/pkg/api/storage"
	"scrabble/pkg/api/user"
	"scrabble/pkg/api/ws"

	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/exp/slog"
)

var CONNECTION_TIMEOUT = time.Second * 15

type API struct {
	App    *fiber.App
	logger *slog.Logger
	Ctrls  Controllers
	Svcs   Services
	Repos  Repositories
	DB     *mongo.Database
}

type Controllers struct {
	UserCtrl         *user.Controller
	WebSocketManager *ws.Manager
}

type Services struct {
	GameSvc *game.Service
	UserSvc *user.Service
	AuthSvc *auth.Service
	RoomSvc *room.Service
}

type Repositories struct {
	GameRepo    *game.Repository
	UserRepo    *user.Repository
	MessageRepo *ws.MessageRepository
	RoomRepo    *room.Repository
}

func New(cfg *config.Config) (*API, error) {
	slog.Info("Opening database...")
	db, err := storage.OpenDB(cfg.MONGODB_URI, cfg.MONGODB_NAME, CONNECTION_TIMEOUT)
	if err != nil {
		return nil, err
	}
	slog.Info("Database opened.")

	var repositories Repositories
	{
		gameRepo := game.NewRepository(db)
		userRepo := user.NewRepository(db)
		messageRepo := ws.NewRepository(db)
		roomRepo := room.NewRepository(db)

		repositories = Repositories{
			GameRepo:    gameRepo,
			UserRepo:    userRepo,
			MessageRepo: messageRepo,
			RoomRepo:    roomRepo,
		}
	}

	var services Services
	{
		authSvc := auth.NewService(cfg.JWT_SIGN_KEY)
		roomSvc, err := room.NewService(repositories.RoomRepo)
		if err != nil {
			return nil, err
		}
		userSvc, err := user.NewService(cfg, repositories.UserRepo, roomSvc)
		gameSvc := game.NewService(repositories.GameRepo, userSvc)
		if err != nil {
			return nil, err
		}

		services = Services{
			GameSvc: gameSvc,
			UserSvc: userSvc,
			AuthSvc: authSvc,
			RoomSvc: roomSvc,
		}
	}

	var controllers Controllers
	{
		wsManager, err := ws.NewManager(repositories.MessageRepo, services.RoomSvc, services.UserSvc, services.GameSvc, services.AuthSvc)
		if err != nil {
			return nil, err
		}
		userCtrl := user.NewController(services.UserSvc, services.AuthSvc)

		controllers = Controllers{
			UserCtrl:         userCtrl,
			WebSocketManager: wsManager,
		}
	}

	api := &API{
		App: fiber.New(fiber.Config{
			ErrorHandler: func(c *fiber.Ctx, err error) error {
				code := fiber.StatusInternalServerError
				var e *fiber.Error
				if errors.As(err, &e) {
					code = e.Code
				}
				return c.Status(code).JSON(err)
			},
		}),
		logger: slog.Default(),
		Ctrls:  controllers,
		Svcs:   services,
		Repos:  repositories,
		DB:     db,
	}

	api.setupRoutes(cfg)

	return api, nil
}

func (api *API) Shutdown() error {
	err := storage.CloseDB(api.DB)
	if err != nil {
		return err
	}

	err = api.App.ShutdownWithTimeout(time.Second * 10)
	if err != nil {
		return err
	}

	return nil
}
