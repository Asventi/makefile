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

NAME = exemple

# ================FILES================ #

MAKE_DIR		:=	.make/
BUILD_DIR		:=	$(MAKE_DIR)build_$(shell git branch --show-current)/
BASE_BUILD_DIR	:= normal/

SRC_DIR			=	src/

OBJS			=	$(patsubst %.c, $(BUILD_DIR)%.o, $(SRC))

DEPS			=	$(patsubst %.c, $(BUILD_DIR)%.d, $(SRC))

# ================ROOT================= #

SRC 		=	exemple.c \

# ===============FORMATS=============== #

SRC += $(addprefix $(EXEMPLE_DIR), $(EXEMPLE_SRC))

EXEMPLE_DIR =	exemple/
EXEMPLE_SRC =	source1.c \
				source2.c \

# ==========LIBS / INCLUDES============ #

LIBS_DIR	=	lib/
LIBS_PATH	=	libft/libmlx.a
LIBS_PATH	:=	$(addprefix $(LIBS_DIR), $(LIBS_PATH))
LIBS		=	$(patsubst lib%.a, %, $(notdir $(LIBS_PATH)))
SYS_LIBS	=	xext x11
SYS_LIBS	:=	$(addprefix "-l", $(SYS_LIBS))

INCS_DIR	=	includes/
INCLUDES	=	$(INCS_DIR) \
				$(addprefix $(dir $(LIBS_PATH)), $(INCS_DIR)) \
				$(dir $(LIBS_PATH))

# ===============CONFIGS=============== #

CC			=	cc
CFLAGS		+=	-Wall -Wextra -Werror
CPPFLAGS	+=	$(addprefix -I, $(INCLUDES)) \
			-MMD -MP

LDFLAGS		+=	$(addprefix -L, $(dir $(LIBS_PATH)))
LDLIBS		+=	$(addprefix -l, $(LIBS))

AR			=	ar
ARFLAGS		=	-rcs

MAKEFLAGS	+=	--no-print-directory

# ================MODES================ #

MODES		:= debug fsanitize optimize full-optimize

MODE_TRACE	:= $(BUILD_DIR).mode_trace
LAST_MODE	:= $(shell cat $(MODE_TRACE) 2>/dev/null)

MODE ?=

ifneq ($(MODE), )
	BUILD_DIR := $(BUILD_DIR)$(MODE)/
else
	BUILD_DIR := $(BUILD_DIR)$(BASE_BUILD_DIR)
endif

ifeq ($(MODE), debug)
	CFLAGS = -g3
else ifeq ($(MODE), fsanitize)
	CFLAGS = -g3 -fsanitize=address
else ifeq ($(MODE), optimize)
	CFLAGS += -O2
else ifeq ($(MODE), full-optimize)
	CFLAGS += -O3
else ifneq ($(MODE),)
	ERROR = MODE
endif

ifneq ($(LAST_MODE), $(MODE))
$(NAME): force
endif

# ================TARGETS============== #

.PHONY: all
all: $(NAME)

show:
	@echo $(SRC_TEST)

$(NAME): $(LIBS_PATH) $(OBJS)
	@echo $(MODE) > $(MODE_TRACE)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) $(LDLIBS) $(SYS_LIBS) -o $(NAME)

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

-include $(DEPS)

.DEFAULT_GOAL := all
