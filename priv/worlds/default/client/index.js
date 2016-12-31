(function() {
    $(document).ready(function() {
        Moongate.init();
        Moongate.callbacks.connected = function() {
            var move = function(e) {
                var level = Moongate.zone('Level', '$');

                level &&
                level.Player &&
                level.Player.call('XY', e.clientX, e.clientY);
            };
            $('#board').on('click', move);
            $('#board').on('touchend', move);
        }
        window.requestAnimationFrame(Functions.tick.bind({entities: {}}));
    });
    var Attributes = {
            drift: ['animation-duration', 's'],
            speed: ['transition-duration', 'ms']
        },
        Functions = {
            addEntity: function(key, member) {
                $('<div class="member"></div>')
                    .appendTo('#board')
                    .attr('data-index', key)
                    .attr('data-origin', member.origin);
            },
            entityExists: function(member) {
                return $('[data-origin="' + member.origin + '"]').length;
            },
            moveEntity: function(x, y) {
                $(this).css('transform', 'translate(' + x + 'px' + ',' + y + 'px)');
            },
            removeEntity: function() {
                $(this).remove();
            },
            refreshEntity: function(member) {
                Functions.moveEntity.call(this, member.x, member.y);
                Functions.updateEntity.call(this, member);

                if (member.origin === Moongate.state.origin_id) {
                    $(this).addClass('me');
                }
            },
            tick: function() {
                var zone = Moongate.zone('Level', '$');

                if (zone && zone.Player) {
                    Moongate.loop(zone.Player.members, function(member, key) {
                        if (!Functions.entityExists(member)) {
                            Functions.addEntity(key, member);
                        }
                    });
                    $('[data-origin]').each(function() {
                        var index = $(this).data('index'),
                            member = zone.Player.members[index];
                            callback = member ?
                                Functions.refreshEntity.bind(this, member) :
                                Functions.removeEntity.bind(this);

                            callback();
                    });
                }
                window.requestAnimationFrame(Functions.tick.bind(this));
            },
            updateEntity: function(member) {
                Object.keys(member).forEach(function(key) {
                    if (Attributes[key]) {
                        $(this).css(Attributes[key][0], member[key] + Attributes[key][1]);
                    }
                }.bind(this));
            }
        };
    })
();