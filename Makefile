# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: pjarnac <pjarnac@student.42lyon.fr>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/11/19 11:53:22 by pjarnac           #+#    #+#              #
#    Updated: 2024/12/20 20:08:38 by pjarnac          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = fdf

# ================FILES================ #

MAKE_DIR		:=	.make/
BUILD_DIR		:=	$(MAKE_DIR)build_$(shell git branch --show-current)/
BASE_BUILD_DIR	:= normal/

SRC_DIR			=	src/

OBJS			=	$(patsubst %.c, $(BUILD_DIR)%.o, $(SRC))

DEPS			=	$(patsubst %.c, $(BUILD_DIR)%.d, $(SRC))

# ================ROOT================= #

SRC 		=	fdf.c \
				hooks.c \

SRC_BONUS	=	fdf_bonus.c \
				hooks_bonus.c \

# ================UTILS================ #

SRC += $(addprefix $(UTILS_DIR), $(UTILS_SRC))

UTILS_DIR =		utils/
UTILS_SRC =		parse.c \
				errors.c \
				colors.c \

# ==============RENDERING============== #

SRC += $(addprefix $(RENDERING_DIR), $(RENDERING_SRC))

RENDERING_DIR =		rendering/
RENDERING_SRC =		render.c \

# ==========LIBS / INCLUDES============ #

LIBS_DIR	=	lib/
LIBS_PATH	=	libft/libft.a minilibx/libmlx.a neflibx/libneflibx.a
LIBS_PATH	:=	$(addprefix $(LIBS_DIR), $(LIBS_PATH))
LIBS		=	$(patsubst lib%.a, %, $(notdir $(LIBS_PATH)))
SYS_LIBS	=	Xext X11 m
SYS_LIBS	:=	$(addprefix -l, $(SYS_LIBS))

INCS_DIR	=	includes/
INCLUDES	=	$(INCS_DIR) \
				$(addsuffix $(INCS_DIR), $(dir $(LIBS_PATH))) \
				$(dir $(LIBS_PATH))

# ===============CONFIGS=============== #

CC			=	cc
CFLAGS		+=	-Wall -Wextra -Werror
CPPFLAGS	+=	$(addprefix -I, $(INCLUDES)) \
			-MMD -MP

LDFLAGS		+=	$(addprefix -L, $(dir $(LIBS_PATH)))
LDLIBS		+=	$(addprefix -l, $(LIBS)) $(SYS_LIBS)

AR			=	ar
ARFLAGS		=	-rcs

MAKEFLAGS	+=	--no-print-directory

# ================MODES================ #

MODES		:= debug fsanitize optimize full-optimize bonus

MODE_TRACE	:= $(BUILD_DIR).mode_trace
LAST_MODE	:= $(shell cat $(MODE_TRACE) 2>/dev/null)

MODE ?=

ifneq ($(MODE), )
	BUILD_DIR := $(BUILD_DIR)$(MODE)/
else
	BUILD_DIR := $(BUILD_DIR)$(BASE_BUILD_DIR)
endif

ifeq ($(MODE), debug)
	CFLAGS = -g3 -Og
else ifeq ($(MODE), fsanitize)
	CFLAGS = -g3 -Og -fsanitize=address
else ifeq ($(MODE), optimize)
	CFLAGS += -O3
else ifeq ($(MODE), full-optimize)
	CFLAGS += -Ofast
else ifeq ($(MODE), bonus)
	SRC := $(SRC_BONUS) $(filter-out $(patsubst %_bonus.c, %.c, $(SRC_BONUS)), $(SRC))
else ifneq ($(MODE),)
	ERROR = MODE
endif

ifneq ($(LAST_MODE), $(MODE))
$(NAME): force
endif

# ================TARGETS============== #

.PHONY: all
all: $(NAME)

$(NAME): $(LIBS_PATH) $(OBJS)
	@echo $(MODE) > $(MODE_TRACE)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) $(LDLIBS) -o $(NAME)

$(BUILD_DIR)%.o: $(SRC_DIR)%.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(LIBS_PATH): force
	@$(MAKE) -C $(@D)

.PHONY: $(MODES)
$(MODES):
	@$(MAKE) MODE=$@

.PHONY: clean
clean:
	-for lib in $(dir $(LIBS_PATH)); do $(MAKE) -s -C $$lib $@; done
	rm -rf $(MAKE_DIR)

.PHONY: fclean
fclean:
	-for lib in $(dir $(LIBS_PATH)); do $(MAKE) -s -C $$lib $@; done
	rm -rf $(MAKE_DIR) $(NAME)

.PHONY: re
re: fclean
	@$(MAKE)

# ================MISC================= #

.PHONY: print-%
print-%:
	@echo $(patsubst print-%,%,$@)=
	@echo $($(patsubst print-%,%,$@))

.PHONY: force
force:

.PHONY: norminette
norminette:
	@norminette $(addprefix $(SRC_DIR), $(SRC)) $(INCS_DIR)

-include $(DEPS)

.DEFAULT_GOAL := all
