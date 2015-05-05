create or replace
package body wpts_rep
as

-- Вернуть стандартный заголовок.
-- Используется при наименовании запуска отчёта.
function get_standard_lbl
return s_std.ndt_identifier
is
begin
    return 'Время запуска: '||std.format_date(sysdate);  -- skfdjfv
end get_standard_lbl;

/*
-- Вычисление и сохранение данных для отчёта "Текущее количество деталей на различных этапах"
function calc_rep_0101 (
    p_dealer_id  in s_std.ndt_id default null
,   p_brand_id   in s_std.ndt_id default null    
) return std.ndt_id
is
    l_rep_activity wpts_rep_activity_svc.base_type;
    l_rep_data     wpts_rep_act_data_0101_svc.base_type;
begin
    l_rep_activity.rep_id := wpts_report_cst.rep_0101; 
    l_rep_activity.lbl    := get_standard_lbl;
    l_rep_activity.brand_id := p_brand_id;
    l_rep_activity.org_id   := p_dealer_id;
    wpts_rep_activity_svc.ins(l_rep_activity);
    
    for r in (
--        with s1 as (
--            select state_class_id, state_class_date, order_no, item_no, designation, price_req_dealer * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1) price_req_dealer
--            from   wpts_spare_part sp
--            where  tech_state_class_id = wpts_tech_state_class_cst.actual
--            and    state_class_id in (
--                wpts_claim_state_class_cst.req_transfer_to_tsc         -- Отправка в ТСЦ
--            ,   wpts_claim_state_class_cst.ready_to_transfer_to_tsc    -- Готов к отправке в ТСЦ
--            ,   wpts_claim_state_class_cst.wait_to_collect_to_tsc      -- Ожидает забора в ТСЦ
--            ,   wpts_claim_state_class_cst.req_storing                 -- Хранение
--            ,   wpts_claim_state_class_cst.req_transfer_to_cs          -- Отправка на ЦС
--            ,   wpts_claim_state_class_cst.ready_to_transfer_to_cs     -- Готов к отправке на ЦС
--            ,   wpts_claim_state_class_cst.wait_to_collect_to_cs       -- Ожидает забора на ЦС
--            ,   wpts_claim_state_class_cst.ready_to_write_off          -- Готов к списанию
--            ,   wpts_claim_state_class_cst.accepted_write_off          -- Подтверждение списания
--            )
--            and (dealer_id = p_dealer_id or p_dealer_id is null)
--            and (brand_id  = p_brand_id  or p_brand_id is null)
--        ), s21 as (
--            select state_class_id, state_class_date, order_no, item_no, designation, price_req_dealer * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1) price_req_dealer
--            from   wpts_spare_part sp
--            where  tech_state_class_id = wpts_tech_state_class_cst.actual
--            and    state_class_id in (
--                wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
--            ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ)
--            )
--            and   res_check_type_id is null -- (результат проверки пустой)
--            and (dealer_id = p_dealer_id or p_dealer_id is null)
--            and (brand_id  = p_brand_id  or p_brand_id is null)
--        ), s22 as (
--            select state_class_id, state_class_date, order_no, item_no, designation, price_req_dealer * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1) price_req_dealer
--            from   wpts_spare_part sp
--            where  tech_state_class_id = wpts_tech_state_class_cst.actual
--            and    state_class_id in (
--                wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
--            )
--            and   res_check_type_id is null -- (результат проверки пустой)
--            and (dealer_id = p_dealer_id or p_dealer_id is null)
--            and (brand_id  = p_brand_id  or p_brand_id is null)
--        ), s3 as (
--            select state_class_id, state_class_date, order_no, item_no, designation, price_req_dealer * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1) price_req_dealer
--            from   wpts_spare_part sp
--            where  tech_state_class_id = wpts_tech_state_class_cst.actual
--            and    state_class_id in (
--                wpts_claim_state_class_cst.not_received_cs             -- Деталь не получена на ЦС
--            ,   wpts_claim_state_class_cst.not_received_tsc            -- Деталь не получена в ТСЦ
--            )
--            and (dealer_id = p_dealer_id or p_dealer_id is null)
--            and (brand_id  = p_brand_id  or p_brand_id is null)
--        )
--        select 1 rep_part_no
--        ,   c.object_id state_class_id
--        ,   nvl(count(*), 0) cnt
--        ,   nvl(sum(price_req_dealer), 0) sum
--        from   s1
--        ,      wpts_claim_state_class c
--        where  c.object_id = s1.state_class_id(+)
--        and    c.object_id in (
--            wpts_claim_state_class_cst.req_transfer_to_tsc         -- Отправка в ТСЦ
--        ,   wpts_claim_state_class_cst.ready_to_transfer_to_tsc    -- Готов к отправке в ТСЦ
--        ,   wpts_claim_state_class_cst.wait_to_collect_to_tsc      -- Ожидает забора в ТСЦ
--        ,   wpts_claim_state_class_cst.req_storing                 -- Хранение
--        ,   wpts_claim_state_class_cst.req_transfer_to_cs          -- Отправка на ЦС
--        ,   wpts_claim_state_class_cst.ready_to_transfer_to_cs     -- Готов к отправке на ЦС
--        ,   wpts_claim_state_class_cst.wait_to_collect_to_cs       -- Ожидает забора на ЦС
--        ,   wpts_claim_state_class_cst.ready_to_write_off          -- Готов к списанию
--        ,   wpts_claim_state_class_cst.accepted_write_off          -- Подтверждение списания
--        )
--        group by c.object_id
--        union all
--        select 2.1 report_part_no, null, count(*), sum(price_req_dealer)
--        from   s21
--        union all
--        select 2.2 report_part_no, null, count(*), sum(price_req_dealer)
--        from   s22
--        union all
--        select 3 report_part_no, null, count(*), sum(price_req_dealer)
--        from   s3
        with s1 as (
            select state_class_id, state_class_date, order_no, item_no, designation
            , price_req_dealer * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1) price_req_dealer
            , recipient_class_id
            from   wpts_spare_part sp
            where  tech_state_class_id = wpts_tech_state_class_cst.actual
            and    state_class_id not in (
                wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
            ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ)
            ,   wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
            )
            and (dealer_id = p_dealer_id or p_dealer_id is null)
            and (brand_id  = p_brand_id  or p_brand_id is null)
--            -- исключить случай, когда у дилера нет контракта на утилизацию, для деталей, ожидающих списания или для которых списание подтверждено
--            and not (
--                state_class_id in (
--                    wpts_claim_state_class_cst.ready_to_write_off          -- Готов к списанию
--                ,   wpts_claim_state_class_cst.accepted_write_off          -- Подтверждение списания
--                )
--                and exists (
--                    select null
--                    from   wpts_org_dealer
--                    where  object_id = sp.dealer_id 
--                    and    contract_util_exists = cst.false
--                )   
--            )    
        ), s2 as (
            select state_class_id, state_class_date, order_no, item_no, designation
            , price_req_dealer * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1) price_req_dealer
            , recipient_class_id
            from   wpts_spare_part sp
            where  tech_state_class_id = wpts_tech_state_class_cst.actual
            and    state_class_id in (
                wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
            ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ)
            ,   wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
            )
            and   res_check_type_id is null -- (результат проверки пустой)
            and (dealer_id = p_dealer_id or p_dealer_id is null)
            and (brand_id  = p_brand_id  or p_brand_id is null)
        )
        select c.object_id state_class_id
        ,   recipient_class_id
        ,   nvl(count(*), 0) cnt
        ,   nvl(sum(price_req_dealer), 0) sum
        ,   max(designation) designation
        from   (select * from s1 union all select * from s2) s
        ,      wpts_claim_state_class c
        where  c.object_id = s.state_class_id(+)
        group by c.object_id, recipient_class_id
    ) loop
        l_rep_data := null;
        l_rep_data.act_id := l_rep_activity.object_id;
        --l_rep_data.rep_part_no := r.rep_part_no;
        l_rep_data.state_class_id := r.state_class_id;
        l_rep_data.recipient_class_id := r.recipient_class_id;
        
        if r.designation is null
        then 
            r.cnt := 0;
            r.sum := 0;
        end if;
        
        l_rep_data.spare_part_cnt := r.cnt;
        l_rep_data.spare_part_sum := r.sum;
        wpts_rep_act_data_0101_svc.ins(l_rep_data);
    end loop;
    
    do_commit;
    return l_rep_activity.object_id;
end calc_rep_0101;

*/

/*
-- Вычисление и сохранение данных для отчёта "Текущее количество деталей на различных этапах"
-- не пинать за громоздкость. будет время - поправлю на динамику и функцию с шаблонами...
function calc_rep_0101 (
    p_dealer_id  in s_std.ndt_id default null
,   p_brand_id   in s_std.ndt_id default null    
) return std.ndt_id
is
    l_rep_activity wpts_rep_activity_svc.base_type;
    
    type
        t_rep_data  is table of wpts_rep_act_data_0101_svc.base_type index by pls_integer;
    
    l_rep_data      t_rep_data;
    l_rep_line      wpts_rep_act_data_0101_svc.base_type;
    
    -- для расчета подитогов
    l_sum_bl        number;
    l_price_bl      number;
    -- индекс
    l_row_num       number;
    -- всего строк
    l_row_count     number  := 37;
begin
    -- начальная инициализация запуска отчета
    l_rep_activity.rep_id := wpts_report_cst.rep_0101; 
    l_rep_activity.lbl    := get_standard_lbl;
    l_rep_activity.brand_id := p_brand_id;
    l_rep_activity.org_id   := p_dealer_id;
    wpts_rep_activity_svc.ins(l_rep_activity);
    
    -- инициализация строк отчета в 0
    for i in 1..l_row_count
    loop
        l_rep_line.act_id       := l_rep_activity.object_id;
        l_rep_line.rep_part_no  := case
                                        when i<=10              then 1
                                        when (i>10) and(i<=13)  then 2
                                        when (i>13) and(i<=18)  then 3
                                        when (i>18) and(i<=21)  then 4
                                        when (i=22)             then 5
                                        when (i>22) and(i<=25)  then 6
                                        else 0
                                    end;
        l_rep_line.pos_name := 'Первичная инициализация';
        l_rep_line.row_num  := i;
        l_rep_line.spare_part_cnt := 0;
        l_rep_line.spare_part_sum := 0;
        l_rep_data(i) := l_rep_line;
    end loop;
    
    -- детали, находящиеся у дилера
    l_sum_bl    := 0;
    l_price_bl  := 0;
    for spr in (
        with
            b1 as   (
                        select state_class_id, count(*) cnt, 
                               sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)) price_req_dealer
                        from   wpts_spare_part sp
                        where  tech_state_class_id = wpts_tech_state_class_cst.actual
                        and    state_class_id not in (
                            wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
                        ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ)
                        ,   wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
                        )
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)
                        group by state_class_id
                    )
        select cnt, price_req_dealer, state_class_id   --state_class_id, count(*), sum(price_req_dealer)
        from b1            
    )
    loop
        -- вычисляем строку
        l_row_num := case spr.state_class_id
                        when wpts_claim_state_class_cst.req_transfer_to_tsc         then 1 -- Отправка в ТСЦ
                        when wpts_claim_state_class_cst.ready_to_transfer_to_tsc    then 2 -- Готов к отправке в ТСЦ
                        when wpts_claim_state_class_cst.wait_to_collect_to_tsc      then 3 -- Ожидает забора в ТСЦ
                        when wpts_claim_state_class_cst.req_storing                 then 4 -- Хранение
                        when wpts_claim_state_class_cst.req_transfer_to_cs          then 5 -- Отправка на ЦС
                        when wpts_claim_state_class_cst.ready_to_transfer_to_cs     then 6 -- Готов к отправке на ЦС
                        when wpts_claim_state_class_cst.wait_to_collect_to_cs       then 7 -- Ожидает забора на ЦС
                        when wpts_claim_state_class_cst.ready_to_write_off          then 8 -- Готов к списанию
                        when wpts_claim_state_class_cst.accepted_write_off          then 9 -- Подтверждение списания
                        else 0
                    end;
        if l_row_num > 0
        then
            l_rep_data(l_row_num).spare_part_cnt := spr.cnt;
            l_sum_bl := l_sum_bl + spr.cnt;
            l_rep_data(l_row_num).spare_part_sum := spr.price_req_dealer;
            l_price_bl := l_price_bl + spr.price_req_dealer;
        end if;
    end loop;

    l_row_num := 10;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl;
    
    --
    -- детали переданные импортеру
    l_sum_bl    := 0;
    l_price_bl  := 0;
    l_row_num   := 11;
    -- Детали, ожидающие проверки в ТСЦ
    for spr in (
        with
            b1 as   (
                        select state_class_id, count(*) cnt, 
                               sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)) price_req_dealer
                        from   wpts_spare_part sp
                        where  tech_state_class_id = wpts_tech_state_class_cst.actual
                        and (  
                                state_class_id in (
                                                    wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
                                                ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ)
                                                )
                            or
                                (   
                                    state_class_id = wpts_claim_state_class_cst.req_storing
                                    and
                                    recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001
                                    and
                                    storage_box_id is null
                                )
                            )
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)     
                        and   res_check_type_id is null -- (результат проверки пустой)
                        group by state_class_id
                    )
        select cnt, price_req_dealer, state_class_id   --state_class_id, count(*), sum(price_req_dealer)
        from b1            
    )
    loop
        l_rep_data(l_row_num).spare_part_cnt := l_rep_data(l_row_num).spare_part_cnt + spr.cnt;
        l_sum_bl := l_sum_bl + spr.cnt;
        l_rep_data(l_row_num).spare_part_sum := l_rep_data(l_row_num).spare_part_sum + spr.price_req_dealer;
        l_price_bl := l_price_bl + spr.cnt;
    end loop;    
    
    -- Детали, ожидающие проверки на ЦС
    l_row_num := l_row_num + 1;
    for spr in (
        with
            b1 as   (
                        select state_class_id, count(*) cnt, 
                               sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)) price_req_dealer
                        from   wpts_spare_part sp
                        where  tech_state_class_id = wpts_tech_state_class_cst.actual
                        and    state_class_id in (
                            wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
                        )
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                        and   res_check_type_id is null -- (результат проверки пустой)
                        group by state_class_id
                    )
        select cnt, price_req_dealer, state_class_id   --state_class_id, count(*), sum(price_req_dealer)
        from b1            
    )
    loop
        l_rep_data(l_row_num).spare_part_cnt := spr.cnt;
        l_sum_bl := l_sum_bl + spr.cnt;
        l_rep_data(l_row_num).spare_part_sum := spr.price_req_dealer;
        l_price_bl := l_price_bl + spr.price_req_dealer;
    end loop; 
    
    l_row_num := l_row_num + 1;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl;   
     
    -- детали переданные в ТСЦ
    l_sum_bl := 0;
    l_price_bl := 0;
    l_row_num := l_row_num + 1;
    
    for spr in (
        with
            -- Детали, ожидающие проверки в ТСЦ аудитором по з/ч
            b1 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               l_row_num rn
                        from   wpts_spare_part sp
                        where  
                            recipient_subclass_id <> wpts_aux_recipient_class_cst.tsc001 -- Класс получателя: ТСЦ (доп. анализ)
                        and state_class_id = wpts_claim_state_class_cst.transfered_to_tsc -- Передан в ТСЦ
                        and res_check_type_id is null -- Проверки нет
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                    ),
            -- Детали, ожидающие проверку специалистом ТСЦ
            b2 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 1) rn
                        from   wpts_spare_part sp
                        where  res_check_type_id is null -- Проверки нет
                          and  (
                                ( 
                                    sp.recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001
                                    and 
                                    state_class_id = wpts_claim_state_class_cst.transfered_to_tsc -- Передан в ТСЦ
                                ) 
                                or 
                                state_class_id = wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ
                             )
                        and tech_state_class_id = WPTS_TECH_STATE_CLASS_CST.actual
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                    ),  
            -- Детали, проверенные в ТСЦ
            b3 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 2) rn
                        from   wpts_spare_part sp
                        where  res_check_type_id is not null -- Проверки есть
                          and tech_state_class_id = wpts_tech_state_class_cst.actual
                          and state_class_id in (
                                  wpts_claim_state_class_cst.transfered_to_tsc -- Передан в ТСЦ
                                , wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ
                             )
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                    ) ,
            -- Детали, отправленные производителю
            b4 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 3) rn
                        from   wpts_spare_part sp
                        where  res_check_type_id is null -- Проверки есть
                          and tech_state_class_id = wpts_tech_state_class_cst.actual
                          and state_class_id = wpts_claim_state_class_cst.transfered_to_manuf  -- Отправлен производителю
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                    ) ,    
            -- Детали, проверенные производителем
            b5 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 4) rn
                        from   wpts_spare_part sp
                        where  res_check_type_id is null -- Проверки есть
                          and tech_state_class_id = wpts_tech_state_class_cst.actual
                          and state_class_id = wpts_claim_state_class_cst.verifed_by_manuf  -- Проверен производителем
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)     
                    ) ,               
            -- Детали, хранящиеся в ТСЦ
            b6 as   (
                        select count(*) cnt, 
                               sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)) price_req_dealer,
                               (l_row_num + 5) rn
                        from   wpts_spare_part sp
                        where  --res_check_type_id is null -- Проверки нет
                               state_class_id in (
                             wpts_claim_state_class_cst.storing_in_tsc             -- Хранение в ТСЦ
                            , wpts_claim_state_class_cst.storing_in_tsc_after_an   -- Хранение в ТСЦ после анализа
                        ) 
                       and not
                                (   
                                    state_class_id = wpts_claim_state_class_cst.req_storing
                                    and
                                    recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001
                                    and
                                    storage_box_id is null
                                )
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                    ),
            -- Детали, ожидающие утилизацию в ТСЦ
            b7 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 6) rn
                        from   wpts_spare_part sp
                        where  state_class_id = wpts_claim_state_class_cst.transfer_to_utilization -- Отправка на утилизацию
                        and sp.recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null) 
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                    )
        select cnt, price_req_dealer, rn
        from b1 
        union all
        select cnt, price_req_dealer, rn
        from b2
        union all
        select cnt, price_req_dealer, rn
        from b3       
        union all
        select cnt, price_req_dealer, rn
        from b4
        union all
        select cnt, price_req_dealer, rn
        from b5
        union all
        select cnt, price_req_dealer, rn
        from b6    
        union all
        select cnt, price_req_dealer, rn
        from b7
    )
    loop
        l_rep_data(spr.rn).spare_part_cnt := spr.cnt;
        l_sum_bl := l_sum_bl + spr.cnt;
        l_rep_data(spr.rn).spare_part_sum := spr.price_req_dealer;
        l_price_bl := l_price_bl + spr.price_req_dealer;
    end loop; 
    
    l_row_num := l_row_num + 7;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl;   
    
    ------------------------------------
    -- Детали, переданные на ЦС
    l_sum_bl := 0;
    l_price_bl := 0;
    
    -- Детали, переданные на ЦС
    for spr in (
        with
            -- Детали, ожидающие проверки на ЦС
            b1 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 2) rn
                        from   wpts_spare_part sp
                        where state_class_id = wpts_claim_state_class_cst.transfered_to_cs
                        and res_check_type_id is null -- Проверки нет
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null) 
                    ),
            -- Детали, проверенные на ЦС
            b2 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 2) rn
                        from   wpts_spare_part sp
                        where state_class_id = wpts_claim_state_class_cst.transfered_to_cs
                        and res_check_type_id is not null -- Проверка есть
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                    ),        
            -- Детали, ожидающие утилизацию на ЦС
            b3 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 3) rn
                        from   wpts_spare_part sp
                        where state_class_id = wpts_claim_state_class_cst.transfer_to_utilization -- Отправка на утилизацию
                        and sp.recipient_subclass_id = wpts_aux_recipient_class_cst.cs999
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                    )
        select cnt, price_req_dealer, rn
        from b1 
        union all
        select cnt, price_req_dealer, rn
        from b2         
        union all
        select cnt, price_req_dealer, rn
        from b3
    )
    loop
        l_rep_data(spr.rn).spare_part_cnt := spr.cnt;
        l_sum_bl := l_sum_bl + spr.cnt;
        l_rep_data(spr.rn).spare_part_sum := spr.price_req_dealer;
        l_price_bl := l_price_bl + spr.price_req_dealer;
    end loop; 
    
    l_row_num := l_row_num + 4;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl;       

    -- Детали, возвращенные дилеру
    l_row_num := l_row_num + 1;
    l_sum_bl := 0;
    l_price_bl := 0;
    for spr in (
        with
            -- Детали, возвращенные из ЦС
            b1 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               l_row_num rn
                        from   wpts_spare_part sp
                        where state_class_id = wpts_claim_state_class_cst.returned_to_dealer --  Возвращен дилеру
                        and recipient_class_id = o_org_type_cst.storing_place -- Центральный склад
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null) 
                    ),
            -- Детали, возвращенные из ТСЦ
            b2 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               (l_row_num + 1) rn
                        from   wpts_spare_part sp
                        where state_class_id  = wpts_claim_state_class_cst.returned_to_dealer --  Возвращен дилеру
                        and tech_state_class_id = wpts_tech_state_class_cst.actual
                        and recipient_class_id = o_org_type_cst.service_center -- Технический сервисный центр
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)   
                    )
        select cnt, price_req_dealer, rn
        from b1 
        union all
        select cnt, price_req_dealer, rn
        from b2 
    )
    loop
        l_rep_data(spr.rn).spare_part_cnt := spr.cnt;
        l_sum_bl := l_sum_bl + spr.cnt;
        l_rep_data(spr.rn).spare_part_sum := spr.price_req_dealer;
        l_price_bl := l_price_bl + spr.price_req_dealer;
    end loop; 
    
    l_row_num := l_row_num + 2;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl;  


    -- Деталь не получена
    l_sum_bl := 0;
    l_price_bl := 0;
    for spr in (
        with
            b1 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               l_row_num + 1 rn
                        from   wpts_spare_part sp
                        where  tech_state_class_id = wpts_tech_state_class_cst.actual
                        and    state_class_id = wpts_claim_state_class_cst.not_received_cs             -- Деталь не получена на ЦС
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)
                    ),
            b2 as   (
                        select count(*) cnt, 
                               nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select exch_rate_deal_imp from wpts_claim where object_id = sp.claim_id), 1)),0) price_req_dealer,
                               l_row_num + 2 rn
                        from   wpts_spare_part sp
                        where  tech_state_class_id = wpts_tech_state_class_cst.actual
                        and    state_class_id = wpts_claim_state_class_cst.not_received_tsc            -- Деталь не получена в ТСЦ
                        and (dealer_id = p_dealer_id or p_dealer_id is null)
                        and (brand_id  = p_brand_id  or p_brand_id is null)
                    )                    
        select cnt, price_req_dealer, rn
        from b1 
        union all
        select cnt, price_req_dealer, rn
        from b2
    )
    loop
        l_rep_data(spr.rn).spare_part_cnt := spr.cnt;
        l_sum_bl := l_sum_bl + spr.cnt;
        l_rep_data(spr.rn).spare_part_sum := spr.price_req_dealer;
        l_price_bl := l_price_bl + spr.price_req_dealer;
    end loop; 
    l_row_num := l_row_num + 3;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl; 

    
    -- Детали, которые должны быть проверены до оплаты
    l_sum_bl := 0;
    l_price_bl := 0;
    l_row_num := l_row_num + 1;
    -- Детали, находящиеся у дилера
    for r in 1..3
    loop
        l_rep_data(l_row_num).spare_part_cnt := l_rep_data(l_row_num).spare_part_cnt + l_rep_data(r).spare_part_cnt;
        l_sum_bl := l_sum_bl + l_rep_data(r).spare_part_cnt;
        l_rep_data(l_row_num).spare_part_sum := l_rep_data(l_row_num).spare_part_sum + l_rep_data(r).spare_part_sum;
        l_price_bl := l_price_bl + l_rep_data(r).spare_part_sum;
    end loop;
 
    -- Детали, находящиеся у импортера
    l_row_num := l_row_num + 1;
    l_rep_data(l_row_num).spare_part_cnt := l_rep_data(11).spare_part_cnt;
    l_sum_bl := l_sum_bl + l_rep_data(11).spare_part_cnt;
    l_rep_data(l_row_num).spare_part_sum := l_rep_data(11).spare_part_sum;
    l_price_bl := l_price_bl + l_rep_data(11).spare_part_sum;

    -- итого
    l_row_num := l_row_num + 1;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl;  
    
    -- Детали, которые должны быть проверены аудиторами по з/ч
    l_sum_bl := 0;
    l_price_bl := 0;
    --ТСЦ
    l_row_num := l_row_num + 1;
    l_rep_data(l_row_num).spare_part_cnt := l_rep_data(11).spare_part_cnt;
    l_sum_bl := l_sum_bl + l_rep_data(11).spare_part_cnt;
    l_rep_data(l_row_num).spare_part_sum := l_rep_data(11).spare_part_sum;
    l_price_bl := l_price_bl + l_rep_data(11).spare_part_sum; 
    -- Центральный склад
    l_row_num := l_row_num + 1;
    l_rep_data(l_row_num).spare_part_cnt := l_rep_data(22).spare_part_cnt;
    l_sum_bl := l_sum_bl + l_rep_data(22).spare_part_cnt;
    l_rep_data(l_row_num).spare_part_sum := l_rep_data(22).spare_part_sum;
    l_price_bl := l_price_bl + l_rep_data(22).spare_part_sum; 
    -- итого
    l_row_num := l_row_num + 1;
    l_rep_data(l_row_num).spare_part_cnt := l_sum_bl;
    l_rep_data(l_row_num).spare_part_sum := l_price_bl;      
    
    -- вставка в буфер отчета
    for r in 1..l_row_count
    loop
        wpts_rep_act_data_0101_svc.ins(l_rep_data(r));
    end loop;
    
    -- возврат
    do_commit;
    return l_rep_activity.object_id;
end;
*/
/*
-- Вычисление и сохранение данных для отчёта "Средние сроки нахождения деталей на различных этапах"
function calc_rep_0102 (
    p_start_date in std.ndt_date
,   p_end_date   in std.ndt_date
,   p_dealer_id  in s_std.ndt_id default null
,   p_brand_id   in s_std.ndt_id default null    
) return std.ndt_id 
is
    l_rep_activity wpts_rep_activity_svc.base_type;
    l_rep_data     wpts_rep_act_data_0102_svc.base_type;
    l_start_date   std.ndt_date := trunc(p_start_date, 'MM');
    l_end_date     std.ndt_date := case when p_end_date >= add_months(std.max_date, -1) then p_end_date else add_months(trunc(p_end_date, 'MM'), 1) end;
begin
    l_rep_activity.rep_id := wpts_report_cst.rep_0102; 
    l_rep_activity.lbl    := 'Период: '||std.format_interval(l_start_date, l_end_date, 'mm.yyyy')||'. '||get_standard_lbl;
    l_rep_activity.period_start_date := l_start_date;
    l_rep_activity.period_end_date := l_end_date;
    l_rep_activity.brand_id := p_brand_id;
    l_rep_activity.org_id   := p_dealer_id;
    wpts_rep_activity_svc.ins(l_rep_activity);
    
    for r in (
        with s1 as (
            select state_class_id, order_no, item_no, designation
            , start_date, end_date 
            from   wpts_mv_sp_state_history sph
            where  tech_state_class_id = wpts_tech_state_class_cst.actual
            and    state_class_id not in (
                wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
            ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ)
            ,   wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
            )
            --and std.ints_intersected(start_date, end_date, p_start_date, p_end_date) = cst.true
            and end_date between nvl(l_start_date, std.min_date) and nvl(l_end_date, std.max_date)
            and (dealer_id = p_dealer_id or p_dealer_id is null)
            and (brand_id  = p_brand_id  or p_brand_id is null)
        ), s2 as (
            select state_class_id, order_no, item_no, designation
            , start_date, end_date  
            from   wpts_mv_sp_state_history sph
            where  tech_state_class_id = wpts_tech_state_class_cst.actual
            and    state_class_id in (
                wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
            ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ)
            ,   wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
            )
            and   res_check_type_id is null -- (результат проверки пустой)
            and end_date between nvl(l_start_date, std.min_date) and nvl(l_end_date, std.max_date)
            and (dealer_id = p_dealer_id or p_dealer_id is null)
            and (brand_id  = p_brand_id  or p_brand_id is null)
        )
        select c.object_id state_class_id
        ,   nvl(round(avg(nvl(end_date, sysdate) - start_date), 0), 0) days_cnt
        from   (select * from s1 union all select * from s2) s
        ,      wpts_claim_state_class c
        where  c.object_id = s.state_class_id(+)
        group by c.object_id
    ) loop
        l_rep_data := null;
        l_rep_data.act_id := l_rep_activity.object_id;
        --l_rep_data.rep_part_no := r.rep_part_no;
        l_rep_data.state_class_id := r.state_class_id;
        l_rep_data.spare_part_days_cnt := r.days_cnt;
        wpts_rep_act_data_0102_svc.ins(l_rep_data);
    end loop;
    
    do_commit;
    return l_rep_activity.object_id;
end calc_rep_0102;
*/

-- Вычисление и сохранение данных для отчёта "Средние сроки нахождения деталей на различных этапах"
function calc_rep_0101 (
    p_dealer_id  in s_std.ndt_id default null
,   p_brand_id   in s_std.ndt_id default null    
) return std.ndt_id 
is
    l_rep_activity  wpts_rep_activity_svc.base_type;

    -- 
    type
        t_rep_data  is table of wpts_rep_act_data_0101_svc.base_type index by pls_integer;
    
    l_rep_data      t_rep_data;
    l_rep_line      wpts_rep_act_data_0101_svc.base_type;
    
    -- количество строк всего
    l_row_count     number;

    -- заготовка под общее выражение
    l_sql_cst   varchar2(4000) :=   'with'||s_std.crlf||
                                    'param as ('||s_std.crlf||
                                    '           select :dealer_id dealer_id, :brand_id brand_id'||s_std.crlf||
                                    '           from dual'||s_std.crlf||
                                    ')'||s_std.crlf||
                                    '<%SELECT_LIST%>'||s_std.crlf||
--                                    'select rr, count(*) spare_part_cnt,'||s_std.crlf||
--                                    'sum(nvl(price_claim,0)) spare_part_sum'||s_std.crlf||
                                      'select decode(grouping(rr),0,rr,10) rr,'||s_std.crlf||
                                      ' count(*) spare_part_cnt, sum(nvl(price_claim,0)) spare_part_sum'||s_std.crlf||
                                    'from (<%UNION_CAUSE%>) s'||s_std.crlf|| 
                                    'where rr <> 0'||s_std.crlf||
                                    'group by rollup(rr)';
--                                    'group by rr';
    l_sql       varchar2(32000);  
    
    -- 
    l_sel_list      varchar2(32000);
    l_num_cause     varchar2(4000);
    l_where_cause   varchar2(4000);
    l_union_sql     varchar2(4000);
    
    
    -- для получения данных
    type
        t_rec_avg   is record(
                                row_num         number,
                                spare_part_cnt  number,
                                spare_part_sum  number
                                );
    type
        t_avg_table is table of t_rec_avg;

    l_tab           t_avg_table;
    
    
    -- вычисление запроса для выборки данных
    function get_select_part(
                            p_num           in number,
                            p_rownum_cause  in varchar2,
                            p_where_cause   in varchar2 default null
--                            p_sum_cause     in varchar2 default null -- номера строк через ',' по которым ищется сумма
                        )
    return varchar2
    is
        l_sql_cst   varchar2(4000) :=   'select <%ROWNUM%>, sph.price_claim'||s_std.crlf||
                                        'from WPTS_V_SP_STATE_HISTORY sph, param'||s_std.crlf||
                                        'where  tech_state_class_id <> wpts_tech_state_class_cst.deleted'||s_std.crlf||
                                        'and (sph.dealer_id = param.dealer_id or param.dealer_id is null)'||s_std.crlf||
                                        'and (sph.brand_id  = param.brand_id  or param.brand_id is null)'||s_std.crlf||
                                        'and (sph.damage_causal  = cst.true)'||s_std.crlf||
                                        '<%WHERE%>';
        l_sql       varchar2(4000);
    begin
        l_sql := l_sql_cst;
        -- если считается не итоговая сумма по нескольким строкам
    --    if p_sum_cause is null
    --    then
            l_sql := replace(l_sql, '<%ROWNUM%>', p_rownum_cause||' rr'); 
            l_sql := replace(l_sql, '<%WHERE%>', s_std.ifnotnull(p_rownum_cause, 'and '||p_where_cause));
            l_sql := ', s'||to_char(p_num)||' as ('||l_sql||')'||s_std.crlf;
    --    else
    --        null;
    --    end if;
        return l_sql;
    end;
begin
    -- начальная инициализация запуска отчета
    l_rep_activity.rep_id := wpts_report_cst.rep_0101; 
    l_rep_activity.lbl    := get_standard_lbl;
    l_rep_activity.brand_id := p_brand_id;
    l_rep_activity.org_id   := p_dealer_id;
    -- сохраняем
    wpts_rep_activity_svc.ins(l_rep_activity);
    
    -- формирование строк отчета
    l_sql := l_sql_cst;
    
    -- детали, находящиеся у дилера
    l_row_count := 1;
 
    l_num_cause := 'case sph.state_class_id
                        when wpts_claim_state_class_cst.req_transfer_to_tsc         then 1 -- Отправка в ТСЦ
                        when wpts_claim_state_class_cst.ready_to_transfer_to_tsc    then 2 -- Готов к отправке в ТСЦ
                        when wpts_claim_state_class_cst.wait_to_collect_to_tsc      then 3 -- Ожидает забора в ТСЦ
                        when wpts_claim_state_class_cst.req_storing                 then 4 -- Хранение
                        when wpts_claim_state_class_cst.req_transfer_to_cs          then 5 -- Отправка на ЦС
                        when wpts_claim_state_class_cst.ready_to_transfer_to_cs     then 6 -- Готов к отправке на ЦС
                        when wpts_claim_state_class_cst.wait_to_collect_to_cs       then 7 -- Ожидает забора на ЦС
                        when wpts_claim_state_class_cst.ready_to_write_off          then 8 -- Готов к списанию
                        when wpts_claim_state_class_cst.accepted_write_off          then 9 -- Подтверждение списания
                        else 0
                    end';
     l_where_cause :=   ' sph.state_class_id not in (
                            wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
                        ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ
                        ,   wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
                        )';
    l_union_sql := 'select * from s'||l_row_count;
    l_sel_list :=  get_select_part(l_row_count, l_num_cause, l_where_cause);

    -- детали переданные импортеру

    -- Детали, ожидающие проверки в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 11;
--    l_where_cause :=   'sph.state_class_id in (
--                            wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
--                        ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ
--                        )'||s_std.crlf|| 
--                       'and sph.res_check_type_id is null'; 
                       
    l_where_cause :=   '('||s_std.crlf|| 
                            'sph.state_class_id in ('||s_std.crlf|| 
                                                    'wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf||            -- Передан в ТСЦ
                                                ',   wpts_claim_state_class_cst.clarification_result_in_tsc'||s_std.crlf||  -- Уточнение результата проверки в ТСЦ)
                                                ')'||s_std.crlf|| 
                            'or'||s_std.crlf|| 
                                '(   '||s_std.crlf|| 
                                    'sph.state_class_id = wpts_claim_state_class_cst.req_storing'||s_std.crlf|| 
                                    'and'||s_std.crlf|| 
                                    'sph.recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001'||s_std.crlf|| 
                                    'and'||s_std.crlf|| 
                                    'sph.storage_box_id is null'||s_std.crlf|| 
                                ')'||s_std.crlf|| 
                            ')'||s_std.crlf|| 
                       'and sph.res_check_type_id is null'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
 /*       
    -- Детали, ожидающие проверки на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 12;
    l_where_cause :=   'sph.state_class_id in (
                            wpts_claim_state_class_cst.transfered_to_cs
                        )'||s_std.crlf||  -- Передан в ЦС
                       'and sph.res_check_type_id is null'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- детали переданные в ТСЦ
    
    -- Детали, ожидающие проверки в ТСЦ аудитором по з/ч
    l_row_count := l_row_count+ 1;
    l_num_cause := 14;
    l_where_cause :=   'sph.recipient_subclass_id <> wpts_aux_recipient_class_cst.tsc001'||s_std.crlf||  -- Класс получателя: ТСЦ (доп. анализ)
                       'and sph.state_class_id = wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf||  -- Передан в ТСЦ
                       'and sph.res_check_type_id is null';  -- Проверки нет
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);

    -- Детали, ожидающие проверку специалистом ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 15;
    l_where_cause :=   'res_check_type_id is null'||s_std.crlf|| -- Проверки нет
                        'and  ('||s_std.crlf||
                                '('||s_std.crlf||
                                '   recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001'||s_std.crlf||
                                '   and '||s_std.crlf||
                                '   state_class_id = wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf|| -- Передан в ТСЦ
                               ' ) '||s_std.crlf||
                               ' or '||s_std.crlf||
                               ' state_class_id = wpts_claim_state_class_cst.clarification_result_in_tsc'||s_std.crlf|| -- Уточнение результата проверки в ТСЦ
                             ')';  -- Проверки нет
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);

    
    -- Детали, проверенные в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 16;
    l_where_cause :=   ' res_check_type_id is not null'||s_std.crlf|| -- Проверки есть
                          'and state_class_id in ('||s_std.crlf||
                                  'wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf|| -- Передан в ТСЦ
                                ', wpts_claim_state_class_cst.clarification_result_in_tsc'||s_std.crlf|| -- Уточнение результата проверки в ТСЦ
                             ')'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);

     -- Детали, отправленные производителю
    l_row_count := l_row_count+ 1;
    l_num_cause := 17;
    l_where_cause :=   ' res_check_type_id is null'||s_std.crlf|| -- Проверки есть
                        ' and state_class_id = wpts_claim_state_class_cst.transfered_to_manuf'; -- Отправлен производителю'
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, проверенные производителем
    l_row_count := l_row_count+ 1;
    l_num_cause := 18;
    l_where_cause :=   'res_check_type_id is null'||s_std.crlf|| -- Проверки есть
                        'and state_class_id = wpts_claim_state_class_cst.verifed_by_manuf';   -- Проверен производителем
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, хранящиеся в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 19;
    l_where_cause :=   'state_class_id in ('||s_std.crlf||
                       '      wpts_claim_state_class_cst.storing_in_tsc'||s_std.crlf||             -- Хранение в ТСЦ
                       '    , wpts_claim_state_class_cst.storing_in_tsc_after_an'||s_std.crlf||   -- Хранение в ТСЦ после анализа
                       ')'||s_std.crlf||
                       'and not'||s_std.crlf||
                                '(  '||s_std.crlf|| 
                                    'state_class_id = wpts_claim_state_class_cst.req_storing'||s_std.crlf||
                                    'and'||s_std.crlf||
                                    'recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001'||s_std.crlf||
                                    'and'||s_std.crlf||
                                    'storage_box_id is null'||s_std.crlf||
                                ')';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, ожидающие утилизацию в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 20;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfer_to_utilization'||s_std.crlf|| -- Отправка на утилизацию
                        'and recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    

    -- Детали, переданные на ЦС

    -- Детали, ожидающие проверки на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 22;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfered_to_cs'||s_std.crlf|| 
                        'and res_check_type_id is null';  -- Проверки нет
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, проверенные на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 23;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfered_to_cs'||s_std.crlf|| 
                        'and res_check_type_id is not null';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, ожидающие утилизацию на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 24;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfer_to_utilization'||s_std.crlf||  -- Отправка на утилизацию
                       ' and recipient_subclass_id = wpts_aux_recipient_class_cst.cs999'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);


    -- Детали, возвращенные дилеру

    -- Детали, возвращенные из ЦС
    l_row_count := l_row_count + 1;
    l_num_cause := 26;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.returned_to_dealer'||s_std.crlf||  --  Возвращен дилеру
                       ' and recipient_class_id = o_org_type_cst.storing_place'; -- Центральный склад';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, возвращенные из ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 27;
    l_where_cause :=   ' state_class_id  = wpts_claim_state_class_cst.returned_to_dealer'||s_std.crlf||  --  Возвращен дилеру
                        'and recipient_class_id = o_org_type_cst.service_center'; -- Технический сервисный центр';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);


    -- Не полученные детали

    -- Детали, не полученные из ЦС
    l_row_count := l_row_count + 1;
    l_num_cause := 29;
    l_where_cause :=   ' state_class_id = wpts_claim_state_class_cst.not_received_cs';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, не полученные из ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 30;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.not_received_tsc';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
*/
    -- вносим в общий селект что получилось
    l_sql := replace(l_sql, '<%SELECT_LIST%>', l_sel_list);
    l_sql := replace(l_sql, '<%UNION_CAUSE%>', l_union_sql);
    
    --msg.show(l_sql);
    -- инициализация строк отчета в 0
    l_row_count := 31;
    for i in 1..l_row_count
    loop
        l_rep_line.act_id               := l_rep_activity.object_id;
        l_rep_line.pos_name             := 'Первичная инициализация';
        l_rep_line.row_num              := i;
        l_rep_line.spare_part_cnt       := 0; --l_rep_data(11).spare_part_cnt;
        l_rep_line.spare_part_sum       := 0; --l_rep_data(11).spare_part_sum;
        l_rep_data(i)                   := l_rep_line;
    end loop;

--    s_mess.put_success(l_sql);
    -- заполняем существующими данными
    execute immediate l_sql
    bulk collect into l_tab
    using  p_dealer_id,  p_brand_id;
    
    for i in 1..l_tab.count
    loop
        l_rep_data(l_tab(i).row_num).spare_part_cnt := l_tab(i).spare_part_cnt;
        l_rep_data(l_tab(i).row_num).spare_part_sum := l_tab(i).spare_part_sum;
    end loop;
    
    -- сумма по первому блоку
    for i in 1..9
    loop
        l_rep_data(10).spare_part_cnt := l_rep_data(10).spare_part_cnt + l_tab(i).spare_part_cnt;
        l_rep_data(10).spare_part_sum := l_rep_data(10).spare_part_sum + l_tab(i).spare_part_sum;
    end loop;
    
    -- вставка в буфер отчета
    for r in 1..l_row_count
    loop
        wpts_rep_act_data_0101_svc.ins(l_rep_data(r));
    end loop;
    
    -- возврат
    do_commit;
    
    return l_rep_activity.object_id;  
end calc_rep_0101;


-- Вычисление и сохранение данных для отчёта "Средние сроки нахождения деталей на различных этапах"
function calc_rep_0102 (
    p_start_date in std.ndt_date
,   p_end_date   in std.ndt_date
,   p_dealer_id  in s_std.ndt_id default null
,   p_brand_id   in s_std.ndt_id default null    
) return std.ndt_id 
is
    l_rep_activity  wpts_rep_activity_svc.base_type;

    -- 
    type
        t_rep_data  is table of wpts_rep_act_data_0102_svc.base_type index by pls_integer;
    
    l_rep_data      t_rep_data;
    l_rep_line      wpts_rep_act_data_0102_svc.base_type;
    
    l_start_date    std.ndt_date := trunc(p_start_date, 'MM');
    l_end_date      std.ndt_date := case when p_end_date >= add_months(std.max_date, -1) then p_end_date else add_months(trunc(p_end_date, 'MM'), 1) end;
    
    -- количество строк всего
    l_row_count     number;

    -- заготовка под общее выражение
    l_sql_cst   varchar2(4000) :=   'with'||s_std.crlf||
                                    'param as ('||s_std.crlf||
                                    '           select :dealer_id dealer_id, :brand_id brand_id, :start_date start_date, :end_date end_date'||s_std.crlf||
                                    '           from dual'||s_std.crlf||
                                    ')'||s_std.crlf||
                                    '<%SELECT_LIST%>'||s_std.crlf||
                                    'select rr, nvl(round(avg(nvl(end_date, sysdate) - start_date), 0), 0) days_cnt'||s_std.crlf||
                                    'from (<%UNION_CAUSE%>) s'||s_std.crlf|| 
                                    'group by rr';
    l_sql       varchar2(32000);  
    
    -- 
    l_sel_list      varchar2(32000);
    l_num_cause     varchar2(4000);
    l_where_cause   varchar2(4000);
    l_union_sql     varchar2(4000);
    
    
    -- для получения данных
    type
        t_rec_avg   is record(
                                row_num     number,
                                avg_count   number
                                );
    type
        t_avg_table is table of t_rec_avg;

    l_tab           t_avg_table;
    
    
    -- вычисление запроса для выборки данных
    function get_select_part(
                            p_num           in number,
                            p_rownum_cause  in varchar2,
                            p_where_cause   in varchar2 default null
--                            p_sum_cause     in varchar2 default null -- номера строк через ',' по которым ищется сумма
                        )
    return varchar2
    is
        l_sql_cst   varchar2(4000) :=   'select <%ROWNUM%>, sph.start_date, sph.end_date'||s_std.crlf||
                                        'from wpts_mv_sp_state_history sph, param'||s_std.crlf||
                                        'where  tech_state_class_id = wpts_tech_state_class_cst.actual'||s_std.crlf||
                                        'and sph.end_date between nvl(param.start_date, std.min_date) and nvl(param.end_date, std.max_date)'||s_std.crlf||
                                        'and (sph.dealer_id = param.dealer_id or param.dealer_id is null)'||s_std.crlf||
                                        'and (sph.brand_id  = param.brand_id  or param.brand_id is null)'||s_std.crlf||
                                        '<%WHERE%>';
        l_sql       varchar2(4000);
    begin
        l_sql := l_sql_cst;
        -- если считается не итоговая сумма по нескольким строкам
    --    if p_sum_cause is null
    --    then
            l_sql := replace(l_sql, '<%ROWNUM%>', p_rownum_cause||' rr'); 
            l_sql := replace(l_sql, '<%WHERE%>', s_std.ifnotnull(p_rownum_cause, 'and '||p_where_cause));
            l_sql := ', s'||to_char(p_num)||' as ('||l_sql||')'||s_std.crlf;
    --    else
    --        null;
    --    end if;
        return l_sql;
    end;
begin 
    -- инициализация экземпляра запуска отчета
    l_rep_activity.rep_id := wpts_report_cst.rep_0102; 
    l_rep_activity.lbl    := 'Период: '||std.format_interval(l_start_date, l_end_date, 'mm.yyyy')||'. '||get_standard_lbl;
    l_rep_activity.period_start_date    := l_start_date;
    l_rep_activity.period_end_date      := l_end_date;
    l_rep_activity.brand_id             := p_brand_id;
    l_rep_activity.org_id               := p_dealer_id;
    -- сохраняем
    wpts_rep_activity_svc.ins(l_rep_activity);

    -- формирование строк отчета
    l_sql := l_sql_cst;
    
    -- детали, находящиеся у дилера
    l_row_count := 1;
 
    l_num_cause := 'case sph.state_class_id
                        when wpts_claim_state_class_cst.req_transfer_to_tsc         then 1 -- Отправка в ТСЦ
                        when wpts_claim_state_class_cst.ready_to_transfer_to_tsc    then 2 -- Готов к отправке в ТСЦ
                        when wpts_claim_state_class_cst.wait_to_collect_to_tsc      then 3 -- Ожидает забора в ТСЦ
                        when wpts_claim_state_class_cst.req_storing                 then 4 -- Хранение
                        when wpts_claim_state_class_cst.req_transfer_to_cs          then 5 -- Отправка на ЦС
                        when wpts_claim_state_class_cst.ready_to_transfer_to_cs     then 6 -- Готов к отправке на ЦС
                        when wpts_claim_state_class_cst.wait_to_collect_to_cs       then 7 -- Ожидает забора на ЦС
                        when wpts_claim_state_class_cst.ready_to_write_off          then 8 -- Готов к списанию
                        when wpts_claim_state_class_cst.accepted_write_off          then 9 -- Подтверждение списания
                        else 0
                    end';
     l_where_cause :=   ' sph.state_class_id not in (
                            wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
                        ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ
                        ,   wpts_claim_state_class_cst.transfered_to_cs            -- Передан на ЦС
                        )';
    l_union_sql := 'select * from s'||l_row_count;
    l_sel_list :=  get_select_part(l_row_count, l_num_cause, l_where_cause);



   -- детали переданные импортеру

    -- Детали, ожидающие проверки в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 11;
--    l_where_cause :=   'sph.state_class_id in (
--                            wpts_claim_state_class_cst.transfered_to_tsc           -- Передан в ТСЦ
--                        ,   wpts_claim_state_class_cst.clarification_result_in_tsc -- Уточнение результата проверки в ТСЦ
--                        )'||s_std.crlf|| 
--                       'and sph.res_check_type_id is null'; 
                       
    l_where_cause :=   '('||s_std.crlf|| 
                            'sph.state_class_id in ('||s_std.crlf|| 
                                                    'wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf||            -- Передан в ТСЦ
                                                ',   wpts_claim_state_class_cst.clarification_result_in_tsc'||s_std.crlf||  -- Уточнение результата проверки в ТСЦ)
                                                ')'||s_std.crlf|| 
                            'or'||s_std.crlf|| 
                                '(   '||s_std.crlf|| 
                                    'sph.state_class_id = wpts_claim_state_class_cst.req_storing'||s_std.crlf|| 
                                    'and'||s_std.crlf|| 
                                    'sph.recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001'||s_std.crlf|| 
                                    'and'||s_std.crlf|| 
                                    'sph.storage_box_id is null'||s_std.crlf|| 
                                ')'||s_std.crlf|| 
                            ')'||s_std.crlf|| 
                       'and sph.res_check_type_id is null'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
        
    -- Детали, ожидающие проверки на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 12;
    l_where_cause :=   'sph.state_class_id in (
                            wpts_claim_state_class_cst.transfered_to_cs
                        )'||s_std.crlf||  -- Передан в ЦС
                       'and sph.res_check_type_id is null'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- детали переданные в ТСЦ
    
    -- Детали, ожидающие проверки в ТСЦ аудитором по з/ч
    l_row_count := l_row_count+ 1;
    l_num_cause := 14;
    l_where_cause :=   'sph.recipient_subclass_id <> wpts_aux_recipient_class_cst.tsc001'||s_std.crlf||  -- Класс получателя: ТСЦ (доп. анализ)
                       'and sph.state_class_id = wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf||  -- Передан в ТСЦ
                       'and sph.res_check_type_id is null';  -- Проверки нет
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);

    -- Детали, ожидающие проверку специалистом ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 15;
    l_where_cause :=   'res_check_type_id is null'||s_std.crlf|| -- Проверки нет
                        'and  ('||s_std.crlf||
                                '('||s_std.crlf||
                                '   recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001'||s_std.crlf||
                                '   and '||s_std.crlf||
                                '   state_class_id = wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf|| -- Передан в ТСЦ
                               ' ) '||s_std.crlf||
                               ' or '||s_std.crlf||
                               ' state_class_id = wpts_claim_state_class_cst.clarification_result_in_tsc'||s_std.crlf|| -- Уточнение результата проверки в ТСЦ
                             ')';  -- Проверки нет
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);

    
    -- Детали, проверенные в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 16;
    l_where_cause :=   ' res_check_type_id is not null'||s_std.crlf|| -- Проверки есть
                          'and state_class_id in ('||s_std.crlf||
                                  'wpts_claim_state_class_cst.transfered_to_tsc'||s_std.crlf|| -- Передан в ТСЦ
                                ', wpts_claim_state_class_cst.clarification_result_in_tsc'||s_std.crlf|| -- Уточнение результата проверки в ТСЦ
                             ')'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);

     -- Детали, отправленные производителю
    l_row_count := l_row_count+ 1;
    l_num_cause := 17;
    l_where_cause :=   ' res_check_type_id is null'||s_std.crlf|| -- Проверки есть
                        ' and state_class_id = wpts_claim_state_class_cst.transfered_to_manuf'; -- Отправлен производителю'
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, проверенные производителем
    l_row_count := l_row_count+ 1;
    l_num_cause := 18;
    l_where_cause :=   'res_check_type_id is null'||s_std.crlf|| -- Проверки есть
                        'and state_class_id = wpts_claim_state_class_cst.verifed_by_manuf';   -- Проверен производителем
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, хранящиеся в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 19;
    l_where_cause :=   'state_class_id in ('||s_std.crlf||
                       '      wpts_claim_state_class_cst.storing_in_tsc'||s_std.crlf||             -- Хранение в ТСЦ
                       '    , wpts_claim_state_class_cst.storing_in_tsc_after_an'||s_std.crlf||   -- Хранение в ТСЦ после анализа
                       ')'||s_std.crlf||
                       'and not'||s_std.crlf||
                                '(  '||s_std.crlf|| 
                                    'state_class_id = wpts_claim_state_class_cst.req_storing'||s_std.crlf||
                                    'and'||s_std.crlf||
                                    'recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001'||s_std.crlf||
                                    'and'||s_std.crlf||
                                    'storage_box_id is null'||s_std.crlf||
                                ')';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, ожидающие утилизацию в ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 20;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfer_to_utilization'||s_std.crlf|| -- Отправка на утилизацию
                        'and recipient_subclass_id = wpts_aux_recipient_class_cst.tsc001';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    

    -- Детали, переданные на ЦС

    -- Детали, ожидающие проверки на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 22;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfered_to_cs'||s_std.crlf|| 
                        'and res_check_type_id is null';  -- Проверки нет
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, проверенные на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 23;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfered_to_cs'||s_std.crlf|| 
                        'and res_check_type_id is not null';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, ожидающие утилизацию на ЦС
    l_row_count := l_row_count+ 1;
    l_num_cause := 24;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.transfer_to_utilization'||s_std.crlf||  -- Отправка на утилизацию
                       ' and recipient_subclass_id = wpts_aux_recipient_class_cst.cs999'; 
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);


    -- Детали, возвращенные дилеру

    -- Детали, возвращенные из ЦС
    l_row_count := l_row_count + 1;
    l_num_cause := 26;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.returned_to_dealer'||s_std.crlf||  --  Возвращен дилеру
                       ' and recipient_class_id = o_org_type_cst.storing_place'; -- Центральный склад';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, возвращенные из ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 27;
    l_where_cause :=   ' state_class_id  = wpts_claim_state_class_cst.returned_to_dealer'||s_std.crlf||  --  Возвращен дилеру
                        'and recipient_class_id = o_org_type_cst.service_center'; -- Технический сервисный центр';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);


    -- Не полученные детали

    -- Детали, не полученные из ЦС
    l_row_count := l_row_count + 1;
    l_num_cause := 29;
    l_where_cause :=   ' state_class_id = wpts_claim_state_class_cst.not_received_cs';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);
    
    -- Детали, не полученные из ТСЦ
    l_row_count := l_row_count+ 1;
    l_num_cause := 30;
    l_where_cause :=   'state_class_id = wpts_claim_state_class_cst.not_received_tsc';  
    l_union_sql := l_union_sql||' union all select * from s'||l_row_count;
    l_sel_list :=  l_sel_list||s_std.crlf||get_select_part(l_row_count, l_num_cause, l_where_cause);

    -- вносим в общий селект что получилось
    l_sql := replace(l_sql, '<%SELECT_LIST%>', l_sel_list);
    l_sql := replace(l_sql, '<%UNION_CAUSE%>', l_union_sql);


--    htp.p(l_sql);    
--    s_mess.put_success(l_sql);
    -- инициализация строк отчета в 0
    l_row_count := 31;
    for i in 1..l_row_count
    loop
        l_rep_line.act_id               := l_rep_activity.object_id;
        l_rep_line.pos_name             := 'Первичная инициализация';
        l_rep_line.row_num              := i;
        l_rep_line.spare_part_days_cnt  := i;
        l_rep_data(i)                   := l_rep_line;
    end loop;

    -- заполняем существующими данными
    execute immediate l_sql
    bulk collect into l_tab
    using  p_dealer_id,  p_brand_id, p_start_date, p_end_date;
    
    for i in 1..l_tab.count
    loop
        l_rep_data(l_tab(i).row_num).spare_part_days_cnt := l_tab(i).avg_count;
    end loop;
    
    -- вставка в буфер отчета
    for r in 1..l_row_count
    loop
        wpts_rep_act_data_0102_svc.ins(l_rep_data(r));
    end loop;
    
    -- возврат
    do_commit;
    
    return l_rep_activity.object_id;  
end calc_rep_0102;

-- Вычисление и сохранение данных для отчёта "Результаты проверки запасных частей"
function calc_rep_0103 (
    p_start_date in std.ndt_date
,   p_end_date   in std.ndt_date
,   p_dealer_id  in s_std.ndt_id default null
,   p_brand_id   in s_std.ndt_id default null    
) return std.ndt_id 
is
    l_rep_activity wpts_rep_activity_svc.base_type;
    l_rep_data     wpts_rep_act_data_0103_svc.base_type;
    l_start_date   std.ndt_date := trunc(p_start_date, 'MM');
    l_end_date     std.ndt_date := case when p_end_date >= add_months(std.max_date, -1) then p_end_date else add_months(trunc(p_end_date, 'MM'), 1) end;
begin
    l_rep_activity.rep_id := wpts_report_cst.rep_0103; 
    l_rep_activity.lbl    := 'Период: '||std.format_interval(l_start_date, l_end_date, 'mm.yyyy')||'. '||get_standard_lbl;
    l_rep_activity.period_start_date := l_start_date;
    l_rep_activity.period_end_date := l_end_date;
    l_rep_activity.brand_id := p_brand_id;
    l_rep_activity.org_id   := p_dealer_id;
    wpts_rep_activity_svc.ins(l_rep_activity);
    
    for r in (
        with s as (
            select res_check_type_id
            ,   trunc(accepted_date, 'MM') rep_month
            ,   count(*) cnt
            ,   nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select nvl(exch_rate_deal_imp,0) from wpts_claim where object_id = sp.claim_id), 1)), 0) sum
            ,   case res_check_type_id
                when wpts_aux_res_check_type_cst.accepted then 0
                when wpts_aux_res_check_type_cst.absent then 1
                when wpts_aux_res_check_type_cst.mechanical_damage then 2
                when wpts_aux_res_check_type_cst.unreasonable_change then 3
                else 10
                end order_no
            from  wpts_spare_part sp
            where accepted_date between nvl(l_start_date, std.min_date) and nvl(l_end_date, std.max_date)
            and   res_check_type_id is not null
            and (dealer_id = p_dealer_id or p_dealer_id is null)
            and (brand_id  = p_brand_id  or p_brand_id is null)
            group by res_check_type_id
            ,   trunc(accepted_date, 'MM') 
        )
        select null res_check_type_id, rep_month, sum(cnt) cnt, sum(sum) sum, 10 rep_part_no
        from   s
        group by rep_month
        union all
        select null res_check_type_id, rep_month, sum(cnt) cnt, sum(sum) sum, 20 rep_part_no
        from   s
        where  res_check_type_id = wpts_aux_res_check_type_cst.accepted
        group by rep_month
        union all
        select null res_check_type_id, rep_month, sum(cnt) cnt, sum(sum) sum, 30 rep_part_no
        from   s
        where  res_check_type_id != wpts_aux_res_check_type_cst.accepted
        group by rep_month
        union all
        select res_check_type_id, rep_month, cnt, sum, 30 + order_no rep_part_no
        from   s
        where  res_check_type_id != wpts_aux_res_check_type_cst.accepted
        order by rep_month, rep_part_no
    ) loop
        l_rep_data := null;
        l_rep_data.act_id := l_rep_activity.object_id;
        l_rep_data.rep_part_no := r.rep_part_no;
        l_rep_data.res_check_type_id := r.res_check_type_id;
        l_rep_data.rep_month := r.rep_month;
        l_rep_data.spare_part_cnt := r.cnt;
        l_rep_data.spare_part_sum := r.sum;
        wpts_rep_act_data_0103_svc.ins(l_rep_data);
    end loop;
    
    -- деталей заменено + проверено в проверочной комнате
    for r in (
        with s as (
                    select 
                        trunc(claim_date, 'MM') rep_month
                    ,   count(*) cnt
                    ,   nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select nvl(exch_rate_deal_imp,0) from wpts_claim where object_id = sp.claim_id), 1)), 0) sum
                    ,   1 order_no
                    from  wpts_spare_part sp
                    where claim_date between nvl(l_start_date, std.min_date) and nvl(l_end_date, std.max_date)
                    and sp.reincarnated_id is null
--                    and   res_check_type_id is not null
                    and  tech_state_class_id <> wpts_tech_state_class_cst.ignored
                    and (dealer_id = p_dealer_id or p_dealer_id is null)
                    and (brand_id  = p_brand_id  or p_brand_id is null)
                    group by trunc(claim_date, 'MM')
                    )
       , s2 as     (
                    select 
                        trunc(accepted_date, 'MM') rep_month
                    ,   count(*) cnt
                    ,   nvl(sum(nvl(price_req_dealer,0) * 1 / nvl((select nvl(exch_rate_deal_imp,0) from wpts_claim where object_id = sp.claim_id), 1)), 0) sum
                    ,   25 order_no
                    from  wpts_spare_part sp
                    where accepted_date between nvl(l_start_date, std.min_date) and nvl(l_end_date, std.max_date)
                    and   res_check_type_id is not null
                    and  state_class_id = wpts_claim_state_class_cst.transfered_to_tsc
                    and  tech_state_class_id <> wpts_tech_state_class_cst.ignored                    
                    and (dealer_id = p_dealer_id or p_dealer_id is null)
                    and (brand_id  = p_brand_id  or p_brand_id is null)
                    group by trunc(accepted_date, 'MM')
                 )
        select rep_month, sum(cnt) cnt, sum(sum) sum, order_no rep_part_no
        from   s
        group by rep_month, order_no
        union all
        select rep_month, sum(cnt) cnt, sum(sum) sum, order_no rep_part_no
        from   s2        
        group by rep_month, order_no
    )
    loop
        l_rep_data := null;
        l_rep_data.act_id := l_rep_activity.object_id;
        l_rep_data.rep_part_no := r.rep_part_no;
        l_rep_data.res_check_type_id := null;
        l_rep_data.rep_month := r.rep_month;
        l_rep_data.spare_part_cnt := r.cnt;
        l_rep_data.spare_part_sum := r.sum;
        wpts_rep_act_data_0103_svc.ins(l_rep_data);
    end loop
    
    
    do_commit;
    return l_rep_activity.object_id;
end calc_rep_0103;


-- Обновить вспомогательную таблицу отчёта для данной детали
procedure refresh_wpts_mv_sp_state_h (
    p_spare_part_id in s_std.ndt_id
) is
    l_cnt_del s_std.ndt_natural;
    l_cnt_ins s_std.ndt_natural;
    l_dealer_no       s_std.ndt_short_id;
    l_repair_order_no s_std.ndt_short_id;
    l_claim_serial_no s_std.ndt_short_id;
    l_claim_date      s_std.ndt_date;  
    l_order_no        s_std.ndt_short_id;
begin
    delete wpts_mv_sp_state_history
    where  spare_part_id = p_spare_part_id;
    
    l_cnt_del := sql%rowcount;

    insert into wpts_mv_sp_state_history
    select *
    from   wpts_v_sp_state_history
    where  spare_part_id = p_spare_part_id;
    
    l_cnt_ins := sql%rowcount;

    do_commit;

    begin
        select dealer_no, repair_order_no, claim_serial_no, claim_date, order_no
        into   l_dealer_no, l_repair_order_no, l_claim_serial_no, l_claim_date, l_order_no
        from   wpts_mv_sp_state_history
        where  spare_part_id = p_spare_part_id
        and    rownum = 1;
    exception
        when no_data_found
        then
            s_mess.put2 (
                p_interrupt   => false
            ,   p_priority    => 1001
            ,   p_source_name => 'WPTS: Обновление вспомогательной таблицы отчётов'
            ,   p_text        => 'Деталь с ID = :P1 - не найдена.'
            ,   p_cause       => ''
            ,   p_prm1        => p_spare_part_id
            ,   p_context_obj_id => p_spare_part_id
            );
            return;
    end;

    s_mess.put2 (
        p_interrupt   => false
    ,   p_priority    => 1001
    ,   p_source_name => 'WPTS: Обновление вспомогательной таблицы отчётов'
    ,   p_text        => 'Обновление данных для детали: :P1 (заявка: :P2). Удалено строк: :P3. Добавлено строк: :P4.'
    ,   p_cause       => ''
    ,   p_prm1        => l_order_no
    ,   p_prm2        => l_dealer_no||' '||l_repair_order_no||' '||l_claim_serial_no||' '||std.format_date(l_claim_date, p_fmt => 'dd.mm.yyyy')
    ,   p_prm3        => l_cnt_del
    ,   p_prm4        => l_cnt_ins
    ,   p_context_obj_id => p_spare_part_id
    );
end refresh_wpts_mv_sp_state_h;

-- Обновить вспомогательную таблицу отчёта для данного интервала времени
procedure refresh_wpts_mv_sp_state_h (
    p_start_date in s_std.ndt_date
,   p_end_date   in s_std.ndt_date
) is
    l_cnt_del s_std.ndt_natural;
    l_cnt_ins s_std.ndt_natural;
begin
    delete wpts_mv_sp_state_history
    where  start_date <= p_end_date
    and    end_date   >= p_start_date;
    
    l_cnt_del := sql%rowcount;

    insert into wpts_mv_sp_state_history
    select *
    from   wpts_v_sp_state_history
    where  start_date <= p_end_date
    and    end_date   >= p_start_date;
    
    l_cnt_ins := sql%rowcount;

    do_commit;
    
    s_mess.put2 (
        p_interrupt   => false
    ,   p_priority    => 1001
    ,   p_source_name => 'WPTS: Обновление вспомогательной таблицы отчётов'
    ,   p_text        => 'Обновление данных за интервал времени: :P1. Удалено строк: :P2. Добавлено строк: :P3.'
    ,   p_cause       => ''
    ,   p_prm1        => std.format_interval(p_start_date, p_end_date)
    ,   p_prm2        => l_cnt_del
    ,   p_prm3        => l_cnt_ins
    ,   p_context_obj_id => null
    );
end refresh_wpts_mv_sp_state_h;

end wpts_rep;
